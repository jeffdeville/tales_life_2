defmodule TalesLife2.Content do
  @moduledoc """
  The Content context manages seeded interview questions.
  """

  import Ecto.Query
  alias TalesLife2.Repo
  alias TalesLife2.Content.Question

  @doc """
  Returns all questions ordered by era and position.
  """
  def list_questions do
    Question
    |> order_by([q], [q.era, q.category, q.position])
    |> Repo.all()
  end

  @doc """
  Returns all questions for a given era, ordered by category and position.
  """
  def list_questions_by_era(era) do
    Question
    |> where([q], q.era == ^era)
    |> order_by([q], [q.category, q.position])
    |> Repo.all()
  end

  @doc """
  Gets a single question. Raises if not found.
  """
  def get_question!(id) do
    Repo.get!(Question, id)
  end

  @doc """
  Returns the list of distinct eras.
  """
  def list_eras do
    Question
    |> select([q], q.era)
    |> distinct(true)
    |> order_by([q], q.era)
    |> Repo.all()
  end

  @doc """
  Returns the list of distinct categories for a given era.
  """
  def list_categories_for_era(era) do
    Question
    |> where([q], q.era == ^era)
    |> select([q], q.category)
    |> distinct(true)
    |> order_by([q], q.category)
    |> Repo.all()
  end
end
