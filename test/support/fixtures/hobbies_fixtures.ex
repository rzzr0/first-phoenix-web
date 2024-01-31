defmodule SecondApps.HobbiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SecondApps.Hobbies` context.
  """

  @doc """
  Generate a hobbie.
  """
  def hobbie_fixture(attrs \\ %{}) do
    {:ok, hobbie} =
      attrs
      |> Enum.into(%{
        hobi1: "some hobi1",
        hobi_lain: "some hobi_lain"
      })
      |> SecondApps.Hobbies.create_hobbie()

    hobbie
  end
end
