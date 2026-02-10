defmodule TalesLife2.Interviews do
  @moduledoc """
  The Interviews context manages interview sessions and responses.
  """

  import Ecto.Query
  alias TalesLife2.Accounts.Scope
  alias TalesLife2.Interviews.{Interview, Response}
  alias TalesLife2.Repo

  @doc """
  Creates an interview for the given scope's user.
  """
  def create_interview(%Scope{user: user}, attrs) do
    %Interview{user_id: user.id}
    |> Interview.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Gets a single interview. Raises if not found.
  """
  def get_interview!(id) do
    Repo.get!(Interview, id)
  end

  @doc """
  Lists all interviews for the given scope's user.
  """
  def list_interviews_for_user(%Scope{user: user}) do
    Interview
    |> where([i], i.user_id == ^user.id)
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
  end

  @doc """
  Lists completed interviews for the given scope's user.
  """
  def list_completed_interviews_for_user(%Scope{user: user}) do
    Interview
    |> where([i], i.user_id == ^user.id and i.status == "completed")
    |> order_by([i], desc: i.inserted_at)
    |> Repo.all()
  end

  @doc """
  Gets an interview with its responses and associated questions preloaded.
  Raises if not found.
  """
  def get_interview_with_responses!(id) do
    Interview
    |> Repo.get!(id)
    |> Repo.preload(responses: :question)
  end

  @doc """
  Saves a response to a question within an interview.
  Creates a new response or updates an existing one.
  """
  def save_response(%Interview{} = interview, attrs) do
    question_id = attrs[:question_id] || attrs["question_id"]

    case Repo.get_by(Response, interview_id: interview.id, question_id: question_id) do
      nil ->
        %Response{interview_id: interview.id}
        |> Response.changeset(attrs)
        |> Repo.insert()

      existing ->
        existing
        |> Response.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Marks an interview as completed.
  """
  def complete_interview(%Interview{} = interview) do
    interview
    |> Interview.changeset(%{status: "completed"})
    |> Repo.update()
  end

  @doc """
  Returns progress information for an interview as a map with
  :total_questions and :answered_questions counts.
  """
  def get_interview_progress(%Interview{} = interview) do
    answered =
      Response
      |> where([r], r.interview_id == ^interview.id)
      |> Repo.aggregate(:count)

    questions_query = questions_for_interview_query(interview)
    total = Repo.aggregate(questions_query, :count)

    %{total_questions: total, answered_questions: answered}
  end

  @doc """
  Returns the ordered list of questions for an interview,
  filtered by the interview's selected eras (or all if none selected).
  """
  def list_questions_for_interview(%Interview{} = interview) do
    interview
    |> questions_for_interview_query()
    |> Repo.all()
  end

  @doc """
  Lists all interviews for the given scope's user with response counts preloaded.
  """
  def list_interviews_with_progress(%Scope{user: user}) do
    interviews = list_interviews_for_user(%Scope{user: user})

    Enum.map(interviews, fn interview ->
      progress = get_interview_progress(interview)
      {interview, progress}
    end)
  end

  defp questions_for_interview_query(%Interview{selected_eras: eras}) do
    alias TalesLife2.Content.Question

    query = from(q in Question, order_by: [q.era, q.category, q.position])

    if eras == [] do
      query
    else
      where(query, [q], q.era in ^eras)
    end
  end
end
