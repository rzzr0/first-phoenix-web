defmodule SecondApps.Hobbies.Hobbie do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hobbies" do
    field :hobi1, :string
    field :hobi_lain, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hobbie, attrs) do
    hobbie
    |> cast(attrs, [:hobi1, :hobi_lain])
    |> validate_required([:hobi1, :hobi_lain])
  end
end
