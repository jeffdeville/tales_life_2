defmodule TalesLife2.Interviews.Interview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "interviews" do
    field :subject_name, :string
    field :status, :string, default: "in_progress"
    field :selected_eras, {:array, :string}, default: []

    belongs_to :user, TalesLife2.Accounts.User
    has_many :responses, TalesLife2.Interviews.Response

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(interview, attrs) do
    interview
    |> cast(attrs, [:subject_name, :status, :selected_eras])
    |> validate_required([:subject_name])
    |> validate_inclusion(:status, ~w(in_progress completed))
    |> validate_selected_eras()
  end

  defp validate_selected_eras(changeset) do
    validate_change(changeset, :selected_eras, fn :selected_eras, eras ->
      valid = ~w(early_life mid_life later_life)

      if Enum.all?(eras, &(&1 in valid)),
        do: [],
        else: [selected_eras: "contains invalid era"]
    end)
  end
end
