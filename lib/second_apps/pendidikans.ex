defmodule SecondApps.Pendidikans do
  @moduledoc """
  The Pendidikans context.
  """

  import Ecto.Query, warn: false
  alias SecondApps.Repo

  alias SecondApps.Pendidikans.Pendidikan

  @doc """
  Returns the list of pendidikans.

  ## Examples

      iex> list_pendidikans()
      [%Pendidikan{}, ...]

  """
  def list_pendidikans do
    Repo.all(Pendidikan)
  end

  @doc """
  Gets a single pendidikan.

  Raises `Ecto.NoResultsError` if the Pendidikan does not exist.

  ## Examples

      iex> get_pendidikan!(123)
      %Pendidikan{}

      iex> get_pendidikan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pendidikan!(id), do: Repo.get!(Pendidikan, id)

  @doc """
  Creates a pendidikan.

  ## Examples

      iex> create_pendidikan(%{field: value})
      {:ok, %Pendidikan{}}

      iex> create_pendidikan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pendidikan(attrs \\ %{}) do
    %Pendidikan{}
    |> Pendidikan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pendidikan.

  ## Examples

      iex> update_pendidikan(pendidikan, %{field: new_value})
      {:ok, %Pendidikan{}}

      iex> update_pendidikan(pendidikan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pendidikan(%Pendidikan{} = pendidikan, attrs) do
    pendidikan
    |> Pendidikan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a pendidikan.

  ## Examples

      iex> delete_pendidikan(pendidikan)
      {:ok, %Pendidikan{}}

      iex> delete_pendidikan(pendidikan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pendidikan(%Pendidikan{} = pendidikan) do
    Repo.delete(pendidikan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pendidikan changes.

  ## Examples

      iex> change_pendidikan(pendidikan)
      %Ecto.Changeset{data: %Pendidikan{}}

  """
  def change_pendidikan(%Pendidikan{} = pendidikan, attrs \\ %{}) do
    Pendidikan.changeset(pendidikan, attrs)
  end
end
