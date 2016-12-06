defmodule PhoenixAppTemplate.UserTest do
  use PhoenixAppTemplate.ModelCase

  alias PhoenixAppTemplate.Repo
  alias PhoenixAppTemplate.User

  @valid_attrs %{email: "user@email.com",
                 name: "some content",
                 password: "some pass",
                 password_confirmation: "some pass"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "crypted_password value is set to hash" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert Comeonin.Bcrypt.checkpw(@valid_attrs[:password],
      Ecto.Changeset.get_change(changeset, :crypted_password))
  end

  test "crypted_password value is not set when password is nil" do
    attrs = Map.drop(@valid_attrs, [:password, :password_confirmation])
    changeset = User.changeset(%User{}, attrs)
    refute Ecto.Changeset.get_change(changeset, :crypted_password)
  end

  test "authenticate returns error when email is nil" do
    assert User.authenticate(nil, "some") == {:error, "Invalid Email/Password combination"}
  end

  test "authenticate returns error when password is nil" do
    assert User.authenticate("some", nil) == {:error, "Invalid Email/Password combination"}
  end

  test "authenticate returns error when user does not exist" do
    assert User.authenticate("invalid", "maybe correct") == {:error, "Invalid Email/Password combination"}
  end

  test "authenticate returns error when password is wrong" do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    assert User.authenticate(@valid_attrs.email, "wrong") == {:error, "Invalid Email/Password combination"}
  end

  test "authenticate returns user when params are valid" do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    user = Repo.get_by(User, email: @valid_attrs.email)
    assert User.authenticate(@valid_attrs.email, @valid_attrs.password) == {:ok, user}
  end
end
