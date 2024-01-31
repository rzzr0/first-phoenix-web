defmodule SecondApps.Repo.Migrations.CreateOrg do
  use Ecto.Migration

  def change do
    create table(:org) do
      add :nama_organisasi, :string
      add :jabatan, :string
      add :rincian, :text
      add :pengalaman, :text

      timestamps(type: :utc_datetime)
    end
  end
end
