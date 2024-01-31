defmodule SecondApps.Kejuaraans do
  @moduledoc """
  The Kejuaraans context.
  """

  import Ecto.Query, warn: false
  alias SecondApps.Repo

  alias SecondApps.Kejuaraans.Kejuaraan

  @doc """
  Returns the list of kejuaraans.

  ## Examples

      iex> list_kejuaraans()
      [%Kejuaraan{}, ...]

  """
  def list_kejuaraans do
    Repo.all(Kejuaraan)
  end

  @doc """
  Gets a single kejuaraan.

  Raises `Ecto.NoResultsError` if the Kejuaraan does not exist.

  ## Examples

      iex> get_kejuaraan!(123)
      %Kejuaraan{}

      iex> get_kejuaraan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kejuaraan!(id), do: Repo.get!(Kejuaraan, id)

  @doc """
  Creates a kejuaraan.

  ## Examples

      iex> create_kejuaraan(%{field: value})
      {:ok, %Kejuaraan{}}

      iex> create_kejuaraan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kejuaraan(attrs \\ %{}) do
    %Kejuaraan{}
    |> Kejuaraan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a kejuaraan.

  ## Examples

      iex> update_kejuaraan(kejuaraan, %{field: new_value})
      {:ok, %Kejuaraan{}}

      iex> update_kejuaraan(kejuaraan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kejuaraan(%Kejuaraan{} = kejuaraan, attrs) do
    kejuaraan
    |> Kejuaraan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a kejuaraan.

  ## Examples

      iex> delete_kejuaraan(kejuaraan)
      {:ok, %Kejuaraan{}}

      iex> delete_kejuaraan(kejuaraan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kejuaraan(%Kejuaraan{} = kejuaraan) do
    Repo.delete(kejuaraan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kejuaraan changes.

  ## Examples

      iex> change_kejuaraan(kejuaraan)
      %Ecto.Changeset{data: %Kejuaraan{}}

  """
  def change_kejuaraan(%Kejuaraan{} = kejuaraan, attrs \\ %{}) do
    Kejuaraan.changeset(kejuaraan, attrs)
  end
end
