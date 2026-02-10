defmodule TalesLife2.Repo.Migrations.CreateResponses do
  use Ecto.Migration

  def change do
    create table(:responses) do
      add :text_content, :text, null: false
      add :interview_id, references(:interviews, on_delete: :delete_all), null: false
      add :question_id, references(:questions, on_delete: :restrict), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:responses, [:interview_id])
    create unique_index(:responses, [:interview_id, :question_id])
  end
end
