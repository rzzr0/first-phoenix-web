defmodule SecondApps.OrganisasionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SecondApps.Organisasions` context.
  """

  @doc """
  Generate a organisaion.
  """
  def organisaion_fixture(attrs \\ %{}) do
    {:ok, organisaion} =
      attrs
      |> Enum.into(%{
        jabatan: "some jabatan",
        nama_organisasi: "some nama_organisasi",
        pengalaman: "some pengalaman",
        rincian: "some rincian"
      })
      |> SecondApps.Organisasions.create_organisaion()

    organisaion
  end
end
