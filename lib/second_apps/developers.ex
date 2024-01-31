defmodule SecondApps.Developers do
  @moduledoc """
  The Developers context.
  """

  import Ecto.Query, warn: false
  alias SecondApps.Repo

  alias SecondApps.Developers.{Developer, DeveloperToken, DeveloperNotifier}

  ## Database getters

  @doc """
  Gets a developer by email.

  ## Examples

      iex> get_developer_by_email("foo@example.com")
      %Developer{}

      iex> get_developer_by_email("unknown@example.com")
      nil

  """
  def get_developer_by_email(email) when is_binary(email) do
    Repo.get_by(Developer, email: email)
  end

  @doc """
  Gets a developer by email and password.

  ## Examples

      iex> get_developer_by_email_and_password("foo@example.com", "correct_password")
      %Developer{}

      iex> get_developer_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_developer_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    developer = Repo.get_by(Developer, email: email)
    if Developer.valid_password?(developer, password), do: developer
  end

  @doc """
  Gets a single developer.

  Raises `Ecto.NoResultsError` if the Developer does not exist.

  ## Examples

      iex> get_developer!(123)
      %Developer{}

      iex> get_developer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_developer!(id), do: Repo.get!(Developer, id)

  ## Developer registration

  @doc """
  Registers a developer.

  ## Examples

      iex> register_developer(%{field: value})
      {:ok, %Developer{}}

      iex> register_developer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_developer(attrs) do
    %Developer{}
    |> Developer.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking developer changes.

  ## Examples

      iex> change_developer_registration(developer)
      %Ecto.Changeset{data: %Developer{}}

  """
  def change_developer_registration(%Developer{} = developer, attrs \\ %{}) do
    Developer.registration_changeset(developer, attrs, hash_password: false, validate_email: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the developer email.

  ## Examples

      iex> change_developer_email(developer)
      %Ecto.Changeset{data: %Developer{}}

  """
  def change_developer_email(developer, attrs \\ %{}) do
    Developer.email_changeset(developer, attrs, validate_email: false)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_developer_email(developer, "valid password", %{email: ...})
      {:ok, %Developer{}}

      iex> apply_developer_email(developer, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_developer_email(developer, password, attrs) do
    developer
    |> Developer.email_changeset(attrs)
    |> Developer.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the developer email using the given token.

  If the token matches, the developer email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_developer_email(developer, token) do
    context = "change:#{developer.email}"

    with {:ok, query} <- DeveloperToken.verify_change_email_token_query(token, context),
         %DeveloperToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(developer_email_multi(developer, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp developer_email_multi(developer, email, context) do
    changeset =
      developer
      |> Developer.email_changeset(%{email: email})
      |> Developer.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:developer, changeset)
    |> Ecto.Multi.delete_all(:tokens, DeveloperToken.by_developer_and_contexts_query(developer, [context]))
  end

  @doc ~S"""
  Delivers the update email instructions to the given developer.

  ## Examples

      iex> deliver_developer_update_email_instructions(developer, current_email, &url(~p"/developers/settings/confirm_email/#{&1})")
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_developer_update_email_instructions(%Developer{} = developer, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, developer_token} = DeveloperToken.build_email_token(developer, "change:#{current_email}")

    Repo.insert!(developer_token)
    DeveloperNotifier.deliver_update_email_instructions(developer, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the developer password.

  ## Examples

      iex> change_developer_password(developer)
      %Ecto.Changeset{data: %Developer{}}

  """
  def change_developer_password(developer, attrs \\ %{}) do
    Developer.password_changeset(developer, attrs, hash_password: false)
  end

  @doc """
  Updates the developer password.

  ## Examples

      iex> update_developer_password(developer, "valid password", %{password: ...})
      {:ok, %Developer{}}

      iex> update_developer_password(developer, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_developer_password(developer, password, attrs) do
    changeset =
      developer
      |> Developer.password_changeset(attrs)
      |> Developer.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:developer, changeset)
    |> Ecto.Multi.delete_all(:tokens, DeveloperToken.by_developer_and_contexts_query(developer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{developer: developer}} -> {:ok, developer}
      {:error, :developer, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_developer_session_token(developer) do
    {token, developer_token} = DeveloperToken.build_session_token(developer)
    Repo.insert!(developer_token)
    token
  end

  @doc """
  Gets the developer with the given signed token.
  """
  def get_developer_by_session_token(token) do
    {:ok, query} = DeveloperToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_developer_session_token(token) do
    Repo.delete_all(DeveloperToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc ~S"""
  Delivers the confirmation email instructions to the given developer.

  ## Examples

      iex> deliver_developer_confirmation_instructions(developer, &url(~p"/developers/confirm/#{&1}"))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_developer_confirmation_instructions(confirmed_developer, &url(~p"/developers/confirm/#{&1}"))
      {:error, :already_confirmed}

  """
  def deliver_developer_confirmation_instructions(%Developer{} = developer, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if developer.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, developer_token} = DeveloperToken.build_email_token(developer, "confirm")
      Repo.insert!(developer_token)
      DeveloperNotifier.deliver_confirmation_instructions(developer, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a developer by the given token.

  If the token matches, the developer account is marked as confirmed
  and the token is deleted.
  """
  def confirm_developer(token) do
    with {:ok, query} <- DeveloperToken.verify_email_token_query(token, "confirm"),
         %Developer{} = developer <- Repo.one(query),
         {:ok, %{developer: developer}} <- Repo.transaction(confirm_developer_multi(developer)) do
      {:ok, developer}
    else
      _ -> :error
    end
  end

  defp confirm_developer_multi(developer) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:developer, Developer.confirm_changeset(developer))
    |> Ecto.Multi.delete_all(:tokens, DeveloperToken.by_developer_and_contexts_query(developer, ["confirm"]))
  end

  ## Reset password

  @doc ~S"""
  Delivers the reset password email to the given developer.

  ## Examples

      iex> deliver_developer_reset_password_instructions(developer, &url(~p"/developers/reset_password/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_developer_reset_password_instructions(%Developer{} = developer, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, developer_token} = DeveloperToken.build_email_token(developer, "reset_password")
    Repo.insert!(developer_token)
    DeveloperNotifier.deliver_reset_password_instructions(developer, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the developer by reset password token.

  ## Examples

      iex> get_developer_by_reset_password_token("validtoken")
      %Developer{}

      iex> get_developer_by_reset_password_token("invalidtoken")
      nil

  """
  def get_developer_by_reset_password_token(token) do
    with {:ok, query} <- DeveloperToken.verify_email_token_query(token, "reset_password"),
         %Developer{} = developer <- Repo.one(query) do
      developer
    else
      _ -> nil
    end
  end

  @doc """
  Resets the developer password.

  ## Examples

      iex> reset_developer_password(developer, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Developer{}}

      iex> reset_developer_password(developer, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_developer_password(developer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:developer, Developer.password_changeset(developer, attrs))
    |> Ecto.Multi.delete_all(:tokens, DeveloperToken.by_developer_and_contexts_query(developer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{developer: developer}} -> {:ok, developer}
      {:error, :developer, changeset, _} -> {:error, changeset}
    end
  end
end
