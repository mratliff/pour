defmodule Pour.Events.Notifier do
  import Swoosh.Email

  alias Pour.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Pour", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  def deliver_new_tasting_notification(user, tasting) do
    deliver(user.email, "New Tasting Event: #{tasting.title}", """

    ==============================

    Hi #{user.email},

    A new tasting event has been announced!

    #{tasting.title}
    #{if tasting.description, do: "\n#{tasting.description}\n", else: ""}
    #{if tasting.date, do: "Date: #{Calendar.strftime(tasting.date, "%B %d, %Y at %I:%M %p")}", else: "Date: TBD"}

    Log in to RSVP and get the location details.

    ==============================
    """)
  end

  def deliver_rsvp_confirmation(user, tasting) do
    deliver(user.email, "RSVP Confirmed: #{tasting.title}", """

    ==============================

    Hi #{user.email},

    Your RSVP for #{tasting.title} has been confirmed!

    #{if tasting.date, do: "Date: #{Calendar.strftime(tasting.date, "%B %d, %Y at %I:%M %p")}", else: "Date: TBD"}
    Location: #{tasting.location || "TBD"}

    We look forward to seeing you there!

    ==============================
    """)
  end

  def deliver_tasting_reminder(user, tasting) do
    deliver(user.email, "Reminder: #{tasting.title}", """

    ==============================

    Hi #{user.email},

    This is a reminder about the upcoming tasting event:

    #{tasting.title}
    #{if tasting.date, do: "Date: #{Calendar.strftime(tasting.date, "%B %d, %Y at %I:%M %p")}", else: "Date: TBD"}
    Location: #{tasting.location || "TBD"}

    See you there!

    ==============================
    """)
  end
end
