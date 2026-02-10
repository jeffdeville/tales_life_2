defmodule TalesLife2.Interviews.Interview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "interviews" do
    field :subject_name, :string
    field :status, :string, default: "in_progress"

    belongs_to :user, TalesLife2.Accounts.User
    has_many :responses, TalesLife2.Interviews.Response

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(interview, attrs) do
    interview
    |> cast(attrs, [:subject_name, :status])
    |> validate_required([:subject_name])
    |> validate_inclusion(:status, ~w(in_progress completed))
  end
end
