defmodule SecondApps.DevelopersTest do
  use SecondApps.DataCase

  alias SecondApps.Developers

  import SecondApps.DevelopersFixtures
  alias SecondApps.Developers.{Developer, DeveloperToken}

  describe "get_developer_by_email/1" do
    test "does not return the developer if the email does not exist" do
      refute Developers.get_developer_by_email("unknown@example.com")
    end

    test "returns the developer if the email exists" do
      %{id: id} = developer = developer_fixture()
      assert %Developer{id: ^id} = Developers.get_developer_by_email(developer.email)
    end
  end

  describe "get_developer_by_email_and_password/2" do
    test "does not return the developer if the email does not exist" do
      refute Developers.get_developer_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the developer if the password is not valid" do
      developer = developer_fixture()
      refute Developers.get_developer_by_email_and_password(developer.email, "invalid")
    end

    test "returns the developer if the email and password are valid" do
      %{id: id} = developer = developer_fixture()

      assert %Developer{id: ^id} =
               Developers.get_developer_by_email_and_password(developer.email, valid_developer_password())
    end
  end

  describe "get_developer!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Developers.get_developer!(-1)
      end
    end

    test "returns the developer with the given id" do
      %{id: id} = developer = developer_fixture()
      assert %Developer{id: ^id} = Developers.get_developer!(developer.id)
    end
  end

  describe "register_developer/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Developers.register_developer(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Developers.register_developer(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Developers.register_developer(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = developer_fixture()
      {:error, changeset} = Developers.register_developer(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Developers.register_developer(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers developers with a hashed password" do
      email = unique_developer_email()
      {:ok, developer} = Developers.register_developer(valid_developer_attributes(email: email))
      assert developer.email == email
      assert is_binary(developer.hashed_password)
      assert is_nil(developer.confirmed_at)
      assert is_nil(developer.password)
    end
  end

  describe "change_developer_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Developers.change_developer_registration(%Developer{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_developer_email()
      password = valid_developer_password()

      changeset =
        Developers.change_developer_registration(
          %Developer{},
          valid_developer_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_developer_email/2" do
    test "returns a developer changeset" do
      assert %Ecto.Changeset{} = changeset = Developers.change_developer_email(%Developer{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_developer_email/3" do
    setup do
      %{developer: developer_fixture()}
    end

    test "requires email to change", %{developer: developer} do
      {:error, changeset} = Developers.apply_developer_email(developer, valid_developer_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{developer: developer} do
      {:error, changeset} =
        Developers.apply_developer_email(developer, valid_developer_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{developer: developer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Developers.apply_developer_email(developer, valid_developer_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{developer: developer} do
      %{email: email} = developer_fixture()
      password = valid_developer_password()

      {:error, changeset} = Developers.apply_developer_email(developer, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{developer: developer} do
      {:error, changeset} =
        Developers.apply_developer_email(developer, "invalid", %{email: unique_developer_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{developer: developer} do
      email = unique_developer_email()
      {:ok, developer} = Developers.apply_developer_email(developer, valid_developer_password(), %{email: email})
      assert developer.email == email
      assert Developers.get_developer!(developer.id).email != email
    end
  end

  describe "deliver_developer_update_email_instructions/3" do
    setup do
      %{developer: developer_fixture()}
    end

    test "sends token through notification", %{developer: developer} do
      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_update_email_instructions(developer, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert developer_token = Repo.get_by(DeveloperToken, token: :crypto.hash(:sha256, token))
      assert developer_token.developer_id == developer.id
      assert developer_token.sent_to == developer.email
      assert developer_token.context == "change:current@example.com"
    end
  end

  describe "update_developer_email/2" do
    setup do
      developer = developer_fixture()
      email = unique_developer_email()

      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_update_email_instructions(%{developer | email: email}, developer.email, url)
        end)

      %{developer: developer, token: token, email: email}
    end

    test "updates the email with a valid token", %{developer: developer, token: token, email: email} do
      assert Developers.update_developer_email(developer, token) == :ok
      changed_developer = Repo.get!(Developer, developer.id)
      assert changed_developer.email != developer.email
      assert changed_developer.email == email
      assert changed_developer.confirmed_at
      assert changed_developer.confirmed_at != developer.confirmed_at
      refute Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not update email with invalid token", %{developer: developer} do
      assert Developers.update_developer_email(developer, "oops") == :error
      assert Repo.get!(Developer, developer.id).email == developer.email
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not update email if developer email changed", %{developer: developer, token: token} do
      assert Developers.update_developer_email(%{developer | email: "current@example.com"}, token) == :error
      assert Repo.get!(Developer, developer.id).email == developer.email
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not update email if token expired", %{developer: developer, token: token} do
      {1, nil} = Repo.update_all(DeveloperToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Developers.update_developer_email(developer, token) == :error
      assert Repo.get!(Developer, developer.id).email == developer.email
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end
  end

  describe "change_developer_password/2" do
    test "returns a developer changeset" do
      assert %Ecto.Changeset{} = changeset = Developers.change_developer_password(%Developer{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Developers.change_developer_password(%Developer{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_developer_password/3" do
    setup do
      %{developer: developer_fixture()}
    end

    test "validates password", %{developer: developer} do
      {:error, changeset} =
        Developers.update_developer_password(developer, valid_developer_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{developer: developer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Developers.update_developer_password(developer, valid_developer_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{developer: developer} do
      {:error, changeset} =
        Developers.update_developer_password(developer, "invalid", %{password: valid_developer_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{developer: developer} do
      {:ok, developer} =
        Developers.update_developer_password(developer, valid_developer_password(), %{
          password: "new valid password"
        })

      assert is_nil(developer.password)
      assert Developers.get_developer_by_email_and_password(developer.email, "new valid password")
    end

    test "deletes all tokens for the given developer", %{developer: developer} do
      _ = Developers.generate_developer_session_token(developer)

      {:ok, _} =
        Developers.update_developer_password(developer, valid_developer_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(DeveloperToken, developer_id: developer.id)
    end
  end

  describe "generate_developer_session_token/1" do
    setup do
      %{developer: developer_fixture()}
    end

    test "generates a token", %{developer: developer} do
      token = Developers.generate_developer_session_token(developer)
      assert developer_token = Repo.get_by(DeveloperToken, token: token)
      assert developer_token.context == "session"

      # Creating the same token for another developer should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%DeveloperToken{
          token: developer_token.token,
          developer_id: developer_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_developer_by_session_token/1" do
    setup do
      developer = developer_fixture()
      token = Developers.generate_developer_session_token(developer)
      %{developer: developer, token: token}
    end

    test "returns developer by token", %{developer: developer, token: token} do
      assert session_developer = Developers.get_developer_by_session_token(token)
      assert session_developer.id == developer.id
    end

    test "does not return developer for invalid token" do
      refute Developers.get_developer_by_session_token("oops")
    end

    test "does not return developer for expired token", %{token: token} do
      {1, nil} = Repo.update_all(DeveloperToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Developers.get_developer_by_session_token(token)
    end
  end

  describe "delete_developer_session_token/1" do
    test "deletes the token" do
      developer = developer_fixture()
      token = Developers.generate_developer_session_token(developer)
      assert Developers.delete_developer_session_token(token) == :ok
      refute Developers.get_developer_by_session_token(token)
    end
  end

  describe "deliver_developer_confirmation_instructions/2" do
    setup do
      %{developer: developer_fixture()}
    end

    test "sends token through notification", %{developer: developer} do
      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_confirmation_instructions(developer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert developer_token = Repo.get_by(DeveloperToken, token: :crypto.hash(:sha256, token))
      assert developer_token.developer_id == developer.id
      assert developer_token.sent_to == developer.email
      assert developer_token.context == "confirm"
    end
  end

  describe "confirm_developer/1" do
    setup do
      developer = developer_fixture()

      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_confirmation_instructions(developer, url)
        end)

      %{developer: developer, token: token}
    end

    test "confirms the email with a valid token", %{developer: developer, token: token} do
      assert {:ok, confirmed_developer} = Developers.confirm_developer(token)
      assert confirmed_developer.confirmed_at
      assert confirmed_developer.confirmed_at != developer.confirmed_at
      assert Repo.get!(Developer, developer.id).confirmed_at
      refute Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not confirm with invalid token", %{developer: developer} do
      assert Developers.confirm_developer("oops") == :error
      refute Repo.get!(Developer, developer.id).confirmed_at
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not confirm email if token expired", %{developer: developer, token: token} do
      {1, nil} = Repo.update_all(DeveloperToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Developers.confirm_developer(token) == :error
      refute Repo.get!(Developer, developer.id).confirmed_at
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end
  end

  describe "deliver_developer_reset_password_instructions/2" do
    setup do
      %{developer: developer_fixture()}
    end

    test "sends token through notification", %{developer: developer} do
      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_reset_password_instructions(developer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert developer_token = Repo.get_by(DeveloperToken, token: :crypto.hash(:sha256, token))
      assert developer_token.developer_id == developer.id
      assert developer_token.sent_to == developer.email
      assert developer_token.context == "reset_password"
    end
  end

  describe "get_developer_by_reset_password_token/1" do
    setup do
      developer = developer_fixture()

      token =
        extract_developer_token(fn url ->
          Developers.deliver_developer_reset_password_instructions(developer, url)
        end)

      %{developer: developer, token: token}
    end

    test "returns the developer with valid token", %{developer: %{id: id}, token: token} do
      assert %Developer{id: ^id} = Developers.get_developer_by_reset_password_token(token)
      assert Repo.get_by(DeveloperToken, developer_id: id)
    end

    test "does not return the developer with invalid token", %{developer: developer} do
      refute Developers.get_developer_by_reset_password_token("oops")
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end

    test "does not return the developer if token expired", %{developer: developer, token: token} do
      {1, nil} = Repo.update_all(DeveloperToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Developers.get_developer_by_reset_password_token(token)
      assert Repo.get_by(DeveloperToken, developer_id: developer.id)
    end
  end

  describe "reset_developer_password/2" do
    setup do
      %{developer: developer_fixture()}
    end

    test "validates password", %{developer: developer} do
      {:error, changeset} =
        Developers.reset_developer_password(developer, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{developer: developer} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Developers.reset_developer_password(developer, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{developer: developer} do
      {:ok, updated_developer} = Developers.reset_developer_password(developer, %{password: "new valid password"})
      assert is_nil(updated_developer.password)
      assert Developers.get_developer_by_email_and_password(developer.email, "new valid password")
    end

    test "deletes all tokens for the given developer", %{developer: developer} do
      _ = Developers.generate_developer_session_token(developer)
      {:ok, _} = Developers.reset_developer_password(developer, %{password: "new valid password"})
      refute Repo.get_by(DeveloperToken, developer_id: developer.id)
    end
  end

  describe "inspect/2 for the Developer module" do
    test "does not include password" do
      refute inspect(%Developer{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
