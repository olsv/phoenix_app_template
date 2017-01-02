defmodule PhoenixAppTemplate.UserTest do
  use PhoenixAppTemplate.ModelCase

  alias PhoenixAppTemplate.Repo
  alias PhoenixAppTemplate.User
  alias PhoenixAppTemplate.Identity
  alias Ueberauth.Auth

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

  test "changeset should have downcased email" do
    changeset = User.changeset(%User{}, %{email: "SOME@user.com"})
    assert changeset.changes.email == "some@user.com"
  end

  test "oauth changeset should have downcased email" do
    changeset = User.oauth_changeset(%User{}, %{email: "SOME@user.com"})
    assert changeset.changes.email == "some@user.com"
  end

  test "authenticate returns error when email is nil" do
    assert User.authenticate(nil, "some") == {:error, "invalid"}
  end

  test "authenticate returns error when password is nil" do
    assert User.authenticate("some", nil) == {:error, "invalid"}
  end

  test "authenticate returns error when user does not exist" do
    assert User.authenticate("invalid", "correct") == {:error, "invalid"}
  end

  test "authenticate returns error when password is wrong" do
    User.changeset(%User{}, @valid_attrs)
    |> Repo.insert
    assert User.authenticate(@valid_attrs.email, "wrong") == {:error, "invalid"}
  end

  test "authenticate returns user when params are valid" do
    User.changeset(%User{}, @valid_attrs) |> Repo.insert
    %{email: email, password: password} = @valid_attrs
    user = Repo.get_by(User, email: email)

    {:ok, record} = User.authenticate(email, password)
    assert record == user
    {:ok, record} = User.authenticate(String.upcase(email), password)
    assert record == user
  end

  test "update_changeset should not validate email" do
    changeset = User.update_changeset(%User{}, Map.drop(@valid_attrs, [:email]))
    assert changeset.valid?
  end

  test "update_changeset should not change email of the existing user" do
    params = Map.merge(@valid_attrs, %{email: "new_email@domen.com"})
    changeset = User.update_changeset(%User{}, params)

    assert changeset.valid?
    refute changeset.changes[:email]
  end

  test "create a user from oauth" do
    email = "newuser@email.com"
    name = "some"
    auth = %Auth{provider: :google, uid: "1", info: %{email: email, name: name}}
    User.get_or_create_by_oauth(auth)
    user = Repo.get_by(User, email: email, name: name)
    assert user
    assert Repo.get_by(Identity, user_id: user.id, provider: "google", uid: "1")
  end

  test "add a social_account to the existing user" do
    {_ok, user} = Repo.insert User.changeset(%User{}, @valid_attrs)
    email = @valid_attrs.email
    name = @valid_attrs.name
    auth = %Auth{provider: :google, uid: "2", info: %{email: email, name: name}}
    User.get_or_create_by_oauth(auth)
    assert Repo.get_by(Identity, user_id: user.id, provider: "google", uid: "2")
  end

  test "return existing user for social account" do
    {_ok, user} = Repo.insert User.changeset(%User{}, @valid_attrs)
    {_ok, _account} = Repo.insert(%Identity{user_id: user.id, provider: "some", uid: "3"})
    auth = %Auth{provider: :some, uid: "3", info: %{}}
    {:ok, new_user} = User.get_or_create_by_oauth(auth)
    assert new_user.id == user.id
  end

  test "return changeset for the invalid oauth" do
    auth = %Auth{provider: :some, uid: "3", info: %{name: "some", email: "invalid"}}
    {:error, changeset} = User.get_or_create_by_oauth(auth)
    refute changeset.valid?
  end
end
