defmodule Thyme.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :approver_id, references(:users)

      timestamps()
    end

    create index(:users, [:email], concurrently: true)
  end
end
