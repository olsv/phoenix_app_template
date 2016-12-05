defmodule SociallApp.UserTest do
  use SociallApp.ModelCase

  alias SociallApp.User

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
end
