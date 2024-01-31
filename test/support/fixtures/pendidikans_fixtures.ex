defmodule SecondApps.PendidikansFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SecondApps.Pendidikans` context.
  """

  @doc """
  Generate a pendidikan.
  """
  def pendidikan_fixture(attrs \\ %{}) do
    {:ok, pendidikan} =
      attrs
      |> Enum.into(%{
        sekolah: "some sekolah"
      })
      |> SecondApps.Pendidikans.create_pendidikan()

    pendidikan
  end
end
