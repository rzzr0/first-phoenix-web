defmodule SecondApps.KejuaraansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SecondApps.Kejuaraans` context.
  """

  @doc """
  Generate a kejuaraan.
  """
  def kejuaraan_fixture(attrs \\ %{}) do
    {:ok, kejuaraan} =
      attrs
      |> Enum.into(%{
        cabor: "some cabor",
        kontingen: "some kontingen",
        sub_cabor: "some sub_cabor"
      })
      |> SecondApps.Kejuaraans.create_kejuaraan()

    kejuaraan
  end
end
