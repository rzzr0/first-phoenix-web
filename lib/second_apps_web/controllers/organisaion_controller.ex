defmodule SecondAppsWeb.OrganisaionController do
  use SecondAppsWeb, :controller

  alias SecondApps.Organisasions
  alias SecondApps.Organisasions.Organisaion

  def index(conn, _params) do
    org = Organisasions.list_org()
    render(conn, :index, org: org)
  end

  def new(conn, _params) do
    changeset = Organisasions.change_organisaion(%Organisaion{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"organisaion" => organisaion_params}) do
    case Organisasions.create_organisaion(organisaion_params) do
      {:ok, organisaion} ->
        conn
        |> put_flash(:info, "Organisaion created successfully.")
        |> redirect(to: ~p"/org/#{organisaion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    organisaion = Organisasions.get_organisaion!(id)
    render(conn, :show, organisaion: organisaion)
  end

  def edit(conn, %{"id" => id}) do
    organisaion = Organisasions.get_organisaion!(id)
    changeset = Organisasions.change_organisaion(organisaion)
    render(conn, :edit, organisaion: organisaion, changeset: changeset)
  end

  def update(conn, %{"id" => id, "organisaion" => organisaion_params}) do
    organisaion = Organisasions.get_organisaion!(id)

    case Organisasions.update_organisaion(organisaion, organisaion_params) do
      {:ok, organisaion} ->
        conn
        |> put_flash(:info, "Organisaion updated successfully.")
        |> redirect(to: ~p"/org/#{organisaion}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, organisaion: organisaion, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    organisaion = Organisasions.get_organisaion!(id)
    {:ok, _organisaion} = Organisasions.delete_organisaion(organisaion)

    conn
    |> put_flash(:info, "Organisaion deleted successfully.")
    |> redirect(to: ~p"/org")
  end
end
