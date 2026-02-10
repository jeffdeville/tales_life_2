defmodule TalesLife2.Repo.Migrations.CreateInterviews do
  use Ecto.Migration

  def change do
    create table(:interviews) do
      add :subject_name, :string, null: false
      add :status, :string, null: false, default: "in_progress"
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:interviews, [:user_id])
    create index(:interviews, [:user_id, :status])
  end
end
