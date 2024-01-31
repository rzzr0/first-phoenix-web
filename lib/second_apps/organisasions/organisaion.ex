defmodule SecondApps.Organisasions.Organisaion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "org" do
    field :nama_organisasi, :string
    field :jabatan, :string
    field :rincian, :string
    field :pengalaman, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organisaion, attrs) do
    organisaion
    |> cast(attrs, [:nama_organisasi, :jabatan, :rincian, :pengalaman])
    |> validate_required([:nama_organisasi, :jabatan, :rincian, :pengalaman])
  end
end
