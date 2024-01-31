defmodule SecondApps.Developers.DeveloperNotifier do
  import Swoosh.Email

  alias SecondApps.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"SecondApps", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(developer, url) do
    deliver(developer.email, "Confirmation instructions", """

    ==============================

    Hi #{developer.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a developer password.
  """
  def deliver_reset_password_instructions(developer, url) do
    deliver(developer.email, "Reset password instructions", """

    ==============================

    Hi #{developer.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a developer email.
  """
  def deliver_update_email_instructions(developer, url) do
    deliver(developer.email, "Update email instructions", """

    ==============================

    Hi #{developer.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
