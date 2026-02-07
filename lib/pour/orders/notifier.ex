defmodule Pour.Orders.Notifier do
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

  def deliver_order_ready_notification(%{user: user} = _order) do
    deliver(user.email, "Your order is ready for pickup!", """

    ==============================

    Hi #{user.email},

    Great news! Your Georgetown Pour order is ready for pickup.

    Please visit the shop at your earliest convenience.

    ==============================
    """)
  end

  def deliver_order_placed_notification(%{user: user} = _order) do
    deliver(user.email, "Order received!", """

    ==============================

    Hi #{user.email},

    We've received your Georgetown Pour order. We'll let you know when it's ready for pickup.

    ==============================
    """)
  end
end
