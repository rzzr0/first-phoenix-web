defmodule SecondApps.Repo.Migrations.CreateHobbies do
  use Ecto.Migration

  def change do
    create table(:hobbies) do
      add :hobi1, :text
      add :hobi_lain, :string

      timestamps(type: :utc_datetime)
    end
  end
end
