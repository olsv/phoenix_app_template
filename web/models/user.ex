defmodule SociallApp.User do
  use SociallApp.Web, :model
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :name, :string
    field :email, :string
    field :crypted_password, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :email, :password, :password_confirmation])
    |> unique_constraint(:email)
    |> validate_required([:name, :email, :password, :password_confirmation])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 6)
    |> hash_password
  end

  defp hash_password(changeset) do
    if password = get_change(changeset, :password) do
      changeset
      |> put_change(:crypted_password, hashpwsalt(password))
    else
      changeset
    end
  end
end
