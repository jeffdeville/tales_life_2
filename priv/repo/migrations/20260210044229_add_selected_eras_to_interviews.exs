defmodule TalesLife2.Repo.Migrations.AddSelectedErasToInterviews do
  use Ecto.Migration

  def change do
    alter table(:interviews) do
      add :selected_eras, {:array, :string}, default: [], null: false
    end
  end
end
