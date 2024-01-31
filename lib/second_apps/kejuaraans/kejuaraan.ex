defmodule SecondApps.Kejuaraans.Kejuaraan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "kejuaraans" do
    field :cabor, :string
    field :sub_cabor, :string
    field :kontingen, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(kejuaraan, attrs) do
    kejuaraan
    |> cast(attrs, [:cabor, :sub_cabor, :kontingen])
    |> validate_required([:cabor, :sub_cabor, :kontingen])
  end
end
