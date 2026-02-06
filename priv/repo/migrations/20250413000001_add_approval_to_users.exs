defmodule Pour.Repo.Migrations.AddApprovalToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :approved, :boolean, default: false, null: false
      add :approved_at, :utc_datetime
    end

    # Update the role default from "user" to "member"
    execute "ALTER TABLE users ALTER COLUMN role SET DEFAULT 'member'",
            "ALTER TABLE users ALTER COLUMN role SET DEFAULT 'user'"

    # Update any existing rows with role "user" to "member"
    execute "UPDATE users SET role = 'member' WHERE role = 'user'",
            "UPDATE users SET role = 'user' WHERE role = 'member'"
  end
end
