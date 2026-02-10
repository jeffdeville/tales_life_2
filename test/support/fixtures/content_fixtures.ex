defmodule TalesLife2.ContentFixtures do
  @moduledoc """
  Test helpers for creating Content entities.
  """

  alias TalesLife2.Content.Question
  alias TalesLife2.Repo

  def question_fixture(attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        prompt_text: "What is your earliest memory?",
        era: "early_life",
        category: "childhood",
        position: System.unique_integer([:positive]),
        interviewing_tip: "Be patient and gentle."
      })

    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert!()
  end
end
