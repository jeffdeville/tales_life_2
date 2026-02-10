defmodule TalesLife2.Repo.Migrations.CreateSharedLinks do
  use Ecto.Migration

  def change do
    create table(:shared_links) do
      add :token, :string, null: false
      add :interview_id, references(:interviews, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:shared_links, [:token])
    create index(:shared_links, [:interview_id])
  end
end
