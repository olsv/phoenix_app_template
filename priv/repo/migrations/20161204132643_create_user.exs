defmodule PhoenixAppTemplate.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :email, :string, unique: true
      add :crypted_password, :string

      timestamps()
    end

  end
end
