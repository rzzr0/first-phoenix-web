defmodule SecondAppsWeb.DeveloperSessionController do
  use SecondAppsWeb, :controller

  alias SecondApps.Developers
  alias SecondAppsWeb.DeveloperAuth

  def create(conn, %{"_action" => "registered"} = params) do
    create(conn, params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:developer_return_to, ~p"/developers/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  defp create(conn, %{"developer" => developer_params}, info) do
    %{"email" => email, "password" => password} = developer_params

    if developer = Developers.get_developer_by_email_and_password(email, password) do
      conn
      |> put_flash(:info, info)
      |> DeveloperAuth.log_in_developer(developer, developer_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email, String.slice(email, 0, 160))
      |> redirect(to: ~p"/developers/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> DeveloperAuth.log_out_developer()
  end
end
