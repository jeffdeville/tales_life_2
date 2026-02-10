defmodule TalesLife2.Sharing do
  @moduledoc """
  The Sharing context manages shareable links to interviews.
  """

  alias TalesLife2.Repo
  alias TalesLife2.Sharing.SharedLink
  alias TalesLife2.Interviews.Interview

  @doc """
  Creates a shared link for the given interview.
  """
  def create_shared_link(%Interview{} = interview) do
    %SharedLink{}
    |> SharedLink.changeset(%{interview_id: interview.id})
    |> Repo.insert()
  end

  @doc """
  Gets an interview by its share token, with responses and questions preloaded.
  Raises if not found.
  """
  def get_interview_by_share_token!(token) do
    shared_link = Repo.get_by!(SharedLink, token: token)

    shared_link.interview_id
    |> TalesLife2.Interviews.get_interview_with_responses!()
  end
end
