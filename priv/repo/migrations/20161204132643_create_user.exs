defmodule PhoenixAppTemplate.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    execute("CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;")

    create table(:users) do
      add :name, :string
      add :email, :citext, null: false
      add :crypted_password, :string

      timestamps()
    end

    create index(:users, [:email], unique: true)
  end
end
