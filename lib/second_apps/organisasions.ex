defmodule SecondApps.Organisasions do
  @moduledoc """
  The Organisasions context.
  """

  import Ecto.Query, warn: false
  alias SecondApps.Repo

  alias SecondApps.Organisasions.Organisaion

  @doc """
  Returns the list of org.

  ## Examples

      iex> list_org()
      [%Organisaion{}, ...]

  """
  def list_org do
    Repo.all(Organisaion)
  end

  @doc """
  Gets a single organisaion.

  Raises `Ecto.NoResultsError` if the Organisaion does not exist.

  ## Examples

      iex> get_organisaion!(123)
      %Organisaion{}

      iex> get_organisaion!(456)
      ** (Ecto.NoResultsError)

  """
  def get_organisaion!(id), do: Repo.get!(Organisaion, id)

  @doc """
  Creates a organisaion.

  ## Examples

      iex> create_organisaion(%{field: value})
      {:ok, %Organisaion{}}

      iex> create_organisaion(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_organisaion(attrs \\ %{}) do
    %Organisaion{}
    |> Organisaion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a organisaion.

  ## Examples

      iex> update_organisaion(organisaion, %{field: new_value})
      {:ok, %Organisaion{}}

      iex> update_organisaion(organisaion, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_organisaion(%Organisaion{} = organisaion, attrs) do
    organisaion
    |> Organisaion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a organisaion.

  ## Examples

      iex> delete_organisaion(organisaion)
      {:ok, %Organisaion{}}

      iex> delete_organisaion(organisaion)
      {:error, %Ecto.Changeset{}}

  """
  def delete_organisaion(%Organisaion{} = organisaion) do
    Repo.delete(organisaion)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking organisaion changes.

  ## Examples

      iex> change_organisaion(organisaion)
      %Ecto.Changeset{data: %Organisaion{}}

  """
  def change_organisaion(%Organisaion{} = organisaion, attrs \\ %{}) do
    Organisaion.changeset(organisaion, attrs)
  end
end
