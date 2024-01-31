defmodule SecondApps.Repo.Migrations.CreatePendidikans do
  use Ecto.Migration

  def change do
    create table(:pendidikans) do
      add :sekolah, :string

      timestamps(type: :utc_datetime)
    end
  end
end
