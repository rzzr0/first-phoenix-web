defmodule SecondApps.Repo.Migrations.CreateKejuaraans do
  use Ecto.Migration

  def change do
    create table(:kejuaraans) do
      add :cabor, :string
      add :sub_cabor, :string
      add :kontingen, :string

      timestamps(type: :utc_datetime)
    end
  end
end
