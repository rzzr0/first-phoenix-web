defmodule SecondApps.Repo.Migrations.CreateDevelopersAuthTables do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    create table(:developers) do
      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :naive_datetime
      timestamps(type: :utc_datetime)
    end

    create unique_index(:developers, [:email])

    create table(:developers_tokens) do
      add :developer_id, references(:developers, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:developers_tokens, [:developer_id])
    create unique_index(:developers_tokens, [:context, :token])
  end
end
