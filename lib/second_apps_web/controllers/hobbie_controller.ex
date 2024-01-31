defmodule SecondAppsWeb.HobbieController do
  use SecondAppsWeb, :controller

  alias SecondApps.Hobbies
  alias SecondApps.Hobbies.Hobbie

  def index(conn, _params) do
    hobbies = Hobbies.list_hobbies()
    render(conn, :index, hobbies: hobbies)
  end

  def new(conn, _params) do
    changeset = Hobbies.change_hobbie(%Hobbie{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"hobbie" => hobbie_params}) do
    case Hobbies.create_hobbie(hobbie_params) do
      {:ok, hobbie} ->
        conn
        |> put_flash(:info, "Hobbie created successfully.")
        |> redirect(to: ~p"/hobbies/#{hobbie}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    hobbie = Hobbies.get_hobbie!(id)
    render(conn, :show, hobbie: hobbie)
  end

  def edit(conn, %{"id" => id}) do
    hobbie = Hobbies.get_hobbie!(id)
    changeset = Hobbies.change_hobbie(hobbie)
    render(conn, :edit, hobbie: hobbie, changeset: changeset)
  end

  def update(conn, %{"id" => id, "hobbie" => hobbie_params}) do
    hobbie = Hobbies.get_hobbie!(id)

    case Hobbies.update_hobbie(hobbie, hobbie_params) do
      {:ok, hobbie} ->
        conn
        |> put_flash(:info, "Hobbie updated successfully.")
        |> redirect(to: ~p"/hobbies/#{hobbie}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, hobbie: hobbie, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    hobbie = Hobbies.get_hobbie!(id)
    {:ok, _hobbie} = Hobbies.delete_hobbie(hobbie)

    conn
    |> put_flash(:info, "Hobbie deleted successfully.")
    |> redirect(to: ~p"/hobbies")
  end
end
