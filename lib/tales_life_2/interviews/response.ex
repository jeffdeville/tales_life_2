defmodule TalesLife2.Interviews.Response do
  use Ecto.Schema
  import Ecto.Changeset

  schema "responses" do
    field :text_content, :string

    belongs_to :interview, TalesLife2.Interviews.Interview
    belongs_to :question, TalesLife2.Content.Question

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(response, attrs) do
    response
    |> cast(attrs, [:text_content, :question_id])
    |> validate_required([:text_content, :question_id])
  end
end
