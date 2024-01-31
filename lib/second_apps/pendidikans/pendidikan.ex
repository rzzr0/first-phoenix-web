defmodule SecondApps.Pendidikans.Pendidikan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pendidikans" do
    field :sekolah, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(pendidikan, attrs) do
    pendidikan
    |> cast(attrs, [:sekolah])
    |> validate_required([:sekolah])
  end
end
