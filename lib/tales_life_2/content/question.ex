defmodule TalesLife2.Content.Question do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :prompt_text, :string
    field :era, :string
    field :category, :string
    field :position, :integer
    field :interviewing_tip, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [:prompt_text, :era, :category, :position, :interviewing_tip])
    |> validate_required([:prompt_text, :era, :category, :position])
    |> validate_inclusion(:era, ~w(early_life mid_life later_life))
    |> validate_number(:position, greater_than_or_equal_to: 1)
  end
end
