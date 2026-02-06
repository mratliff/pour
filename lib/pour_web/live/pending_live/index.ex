defmodule PourWeb.PendingLive.Index do
  use PourWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm mt-20 text-center">
      <h1 class="text-2xl font-semibold text-gray-900">Account Pending Approval</h1>
      <p class="mt-4 text-base text-gray-600">
        Your account is pending approval. You'll receive an email when your account has been approved.
      </p>
      <div class="mt-8">
        <.link
          href={~p"/users/log-out"}
          method="delete"
          class="text-sm font-semibold text-indigo-600 hover:text-indigo-500"
        >
          Log out
        </.link>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
