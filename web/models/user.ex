defmodule SociallApp.User do
  use SociallApp.Web, :model
  import Comeonin.Bcrypt, only: [hashpwsalt: 1, checkpw: 2, dummy_checkpw: 0]

  alias SociallApp.Repo
  alias SociallApp.User

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

  def authenticate(email, password)
    when not is_nil(email) and not is_nil(password) do
    if user = Repo.get_by(User, email: email) do
      if checkpw(password, user.crypted_password) do
        {:ok, user}
      else
        handle_invalid_user()
      end
    else
      handle_invalid_user()
    end
  end

  def authenticate(_email, _password), do: handle_invalid_user()

  defp handle_invalid_user() do
    dummy_checkpw() # prevent time based attacks
    {:error, "Invalid Email/Password combination"}
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
