defmodule TalesLife2.Sharing.SharedLink do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "shared_links" do
    field :token, :string

    belongs_to :interview, TalesLife2.Interviews.Interview

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(shared_link, attrs) do
    shared_link
    |> cast(attrs, [:interview_id])
    |> validate_required([:interview_id])
    |> generate_token()
    |> unique_constraint(:token)
  end

  defp generate_token(changeset) do
    if get_field(changeset, :token) do
      changeset
    else
      put_change(changeset, :token, :crypto.strong_rand_bytes(32) |> Base.url_encode64())
    end
  end
end
