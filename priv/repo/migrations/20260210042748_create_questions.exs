defmodule TalesLife2.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :prompt_text, :text, null: false
      add :era, :string, null: false
      add :category, :string, null: false
      add :position, :integer, null: false
      add :interviewing_tip, :text

      timestamps(type: :utc_datetime)
    end

    create index(:questions, [:era])
    create index(:questions, [:era, :category])
  end
end
