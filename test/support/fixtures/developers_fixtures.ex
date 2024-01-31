defmodule SecondApps.DevelopersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SecondApps.Developers` context.
  """

  def unique_developer_email, do: "developer#{System.unique_integer()}@example.com"
  def valid_developer_password, do: "hello world!"

  def valid_developer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_developer_email(),
      password: valid_developer_password()
    })
  end

  def developer_fixture(attrs \\ %{}) do
    {:ok, developer} =
      attrs
      |> valid_developer_attributes()
      |> SecondApps.Developers.register_developer()

    developer
  end

  def extract_developer_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
