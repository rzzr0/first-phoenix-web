defmodule SecondApps.Hobbies do
  @moduledoc """
  The Hobbies context.
  """

  import Ecto.Query, warn: false
  alias SecondApps.Repo

  alias SecondApps.Hobbies.Hobbie

  @doc """
  Returns the list of hobbies.

  ## Examples

      iex> list_hobbies()
      [%Hobbie{}, ...]

  """
  def list_hobbies do
    Repo.all(Hobbie)
  end

  @doc """
  Gets a single hobbie.

  Raises `Ecto.NoResultsError` if the Hobbie does not exist.

  ## Examples

      iex> get_hobbie!(123)
      %Hobbie{}

      iex> get_hobbie!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hobbie!(id), do: Repo.get!(Hobbie, id)

  @doc """
  Creates a hobbie.

  ## Examples

      iex> create_hobbie(%{field: value})
      {:ok, %Hobbie{}}

      iex> create_hobbie(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hobbie(attrs \\ %{}) do
    %Hobbie{}
    |> Hobbie.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hobbie.

  ## Examples

      iex> update_hobbie(hobbie, %{field: new_value})
      {:ok, %Hobbie{}}

      iex> update_hobbie(hobbie, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hobbie(%Hobbie{} = hobbie, attrs) do
    hobbie
    |> Hobbie.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hobbie.

  ## Examples

      iex> delete_hobbie(hobbie)
      {:ok, %Hobbie{}}

      iex> delete_hobbie(hobbie)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hobbie(%Hobbie{} = hobbie) do
    Repo.delete(hobbie)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hobbie changes.

  ## Examples

      iex> change_hobbie(hobbie)
      %Ecto.Changeset{data: %Hobbie{}}

  """
  def change_hobbie(%Hobbie{} = hobbie, attrs \\ %{}) do
    Hobbie.changeset(hobbie, attrs)
  end
end
