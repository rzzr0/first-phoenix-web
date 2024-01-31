defmodule SecondAppsWeb.KejuaraanController do
  use SecondAppsWeb, :controller

  alias SecondApps.Kejuaraans
  alias SecondApps.Kejuaraans.Kejuaraan

  def index(conn, _params) do
    kejuaraans = Kejuaraans.list_kejuaraans()
    render(conn, :index, kejuaraans: kejuaraans)
  end

  def new(conn, _params) do
    changeset = Kejuaraans.change_kejuaraan(%Kejuaraan{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"kejuaraan" => kejuaraan_params}) do
    case Kejuaraans.create_kejuaraan(kejuaraan_params) do
      {:ok, kejuaraan} ->
        conn
        |> put_flash(:info, "Kejuaraan created successfully.")
        |> redirect(to: ~p"/kejuaraans/#{kejuaraan}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    kejuaraan = Kejuaraans.get_kejuaraan!(id)
    render(conn, :show, kejuaraan: kejuaraan)
  end

  def edit(conn, %{"id" => id}) do
    kejuaraan = Kejuaraans.get_kejuaraan!(id)
    changeset = Kejuaraans.change_kejuaraan(kejuaraan)
    render(conn, :edit, kejuaraan: kejuaraan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kejuaraan" => kejuaraan_params}) do
    kejuaraan = Kejuaraans.get_kejuaraan!(id)

    case Kejuaraans.update_kejuaraan(kejuaraan, kejuaraan_params) do
      {:ok, kejuaraan} ->
        conn
        |> put_flash(:info, "Kejuaraan updated successfully.")
        |> redirect(to: ~p"/kejuaraans/#{kejuaraan}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, kejuaraan: kejuaraan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kejuaraan = Kejuaraans.get_kejuaraan!(id)
    {:ok, _kejuaraan} = Kejuaraans.delete_kejuaraan(kejuaraan)

    conn
    |> put_flash(:info, "Kejuaraan deleted successfully.")
    |> redirect(to: ~p"/kejuaraans")
  end
end
