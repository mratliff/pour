defmodule PourWeb.AdminLive.Users do
  use PourWeb, :live_view

  alias Pour.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, Accounts.list_users())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-4xl px-4 py-8">
      <h1 class="text-2xl font-semibold text-gray-900 mb-8">User Management</h1>

      <div class="overflow-hidden shadow ring-1 ring-black ring-opacity-5 rounded-lg">
        <table class="min-w-full divide-y divide-gray-300">
          <thead class="bg-gray-50">
            <tr>
              <th class="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900">Email</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Role</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</th>
              <th class="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Registered</th>
              <th class="relative py-3.5 pl-3 pr-4 text-right text-sm font-semibold text-gray-900">
                Actions
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-200 bg-white">
            <tr :for={user <- @users} class="hover:bg-gray-50">
              <td class="whitespace-nowrap py-4 pl-4 pr-3 text-sm font-medium text-gray-900">
                {user.email}
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                <form phx-change="change_role" phx-value-user-id={user.id}>
                  <select
                    name="role"
                    class="rounded-md border-gray-300 text-sm"
                    disabled={user.id == @current_scope.user.id}
                  >
                    <option value="member" selected={user.role == "member"}>member</option>
                    <option value="admin" selected={user.role == "admin"}>admin</option>
                    <option value="shop" selected={user.role == "shop"}>shop</option>
                  </select>
                </form>
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm">
                <span
                  :if={user.approved}
                  class="inline-flex items-center rounded-full bg-green-100 px-2.5 py-0.5 text-xs font-medium text-green-800"
                >
                  Approved
                </span>
                <span
                  :if={!user.approved}
                  class="inline-flex items-center rounded-full bg-yellow-100 px-2.5 py-0.5 text-xs font-medium text-yellow-800"
                >
                  Pending
                </span>
              </td>
              <td class="whitespace-nowrap px-3 py-4 text-sm text-gray-500">
                {Calendar.strftime(user.inserted_at, "%b %d, %Y")}
              </td>
              <td class="whitespace-nowrap py-4 pl-3 pr-4 text-right text-sm space-x-2">
                <button
                  :if={!user.approved}
                  phx-click="approve"
                  phx-value-id={user.id}
                  class="text-indigo-600 hover:text-indigo-900 font-medium"
                >
                  Approve
                </button>
                <button
                  :if={!user.approved}
                  phx-click="reject"
                  phx-value-id={user.id}
                  data-confirm="Are you sure you want to reject this user? This will delete their account."
                  class="text-red-600 hover:text-red-900 font-medium"
                >
                  Reject
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("approve", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    socket =
      case Accounts.approve_user(user) do
        {:ok, _user} -> put_flash(socket, :info, "#{user.email} approved")
        {:error, _} -> put_flash(socket, :error, "Failed to approve #{user.email}")
      end

    {:noreply, assign(socket, :users, Accounts.list_users())}
  end

  def handle_event("reject", %{"id" => id}, socket) do
    user = Accounts.get_user!(id)

    socket =
      case Accounts.reject_user(user) do
        {:ok, _} -> put_flash(socket, :info, "#{user.email} rejected")
        {:error, _} -> put_flash(socket, :error, "Failed to reject #{user.email}")
      end

    {:noreply, assign(socket, :users, Accounts.list_users())}
  end

  def handle_event("change_role", %{"role" => role, "user-id" => id}, socket) do
    user = Accounts.get_user!(id)

    socket =
      case Accounts.update_user_role(user, role) do
        {:ok, _user} -> put_flash(socket, :info, "Role updated for #{user.email}")
        {:error, _} -> put_flash(socket, :error, "Failed to update role for #{user.email}")
      end

    {:noreply, assign(socket, :users, Accounts.list_users())}
  end
end
