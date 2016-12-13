defmodule PhoenixAppTemplate.Repo.Migrations.CreateIdentity do
  use Ecto.Migration

  def change do
    create table(:identities, primary_key: false) do
      add :provider, :string, null: false
      add :uid, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create unique_index(:identities, [:user_id, :provider, :uid], name: :identity_idx)
  end
end
