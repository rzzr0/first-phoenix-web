defmodule SecondAppsWeb.PendidikanController do
  use SecondAppsWeb, :controller

  alias SecondApps.Pendidikans
  alias SecondApps.Pendidikans.Pendidikan

  def index(conn, _params) do
    pendidikans = Pendidikans.list_pendidikans()
    render(conn, :index, pendidikans: pendidikans)
  end

  def new(conn, _params) do
    changeset = Pendidikans.change_pendidikan(%Pendidikan{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"pendidikan" => pendidikan_params}) do
    case Pendidikans.create_pendidikan(pendidikan_params) do
      {:ok, pendidikan} ->
        conn
        |> put_flash(:info, "Pendidikan created successfully.")
        |> redirect(to: ~p"/pendidikans/#{pendidikan}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pendidikan = Pendidikans.get_pendidikan!(id)
    render(conn, :show, pendidikan: pendidikan)
  end

  def edit(conn, %{"id" => id}) do
    pendidikan = Pendidikans.get_pendidikan!(id)
    changeset = Pendidikans.change_pendidikan(pendidikan)
    render(conn, :edit, pendidikan: pendidikan, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pendidikan" => pendidikan_params}) do
    pendidikan = Pendidikans.get_pendidikan!(id)

    case Pendidikans.update_pendidikan(pendidikan, pendidikan_params) do
      {:ok, pendidikan} ->
        conn
        |> put_flash(:info, "Pendidikan updated successfully.")
        |> redirect(to: ~p"/pendidikans/#{pendidikan}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, pendidikan: pendidikan, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pendidikan = Pendidikans.get_pendidikan!(id)
    {:ok, _pendidikan} = Pendidikans.delete_pendidikan(pendidikan)

    conn
    |> put_flash(:info, "Pendidikan deleted successfully.")
    |> redirect(to: ~p"/pendidikans")
  end
end
