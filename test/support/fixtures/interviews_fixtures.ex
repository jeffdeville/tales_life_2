defmodule TalesLife2.InterviewsFixtures do
  @moduledoc """
  Test helpers for creating Interviews entities.
  """

  alias TalesLife2.Interviews

  def interview_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        subject_name: "Grandma #{System.unique_integer([:positive])}"
      })

    {:ok, interview} = Interviews.create_interview(scope, attrs)
    interview
  end
end
