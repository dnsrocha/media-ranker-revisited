require "test_helper"

describe UsersController do
  # Tests written for Oauth.
  describe "auth_callback" do
    it "logs in an existing user and redirects to the root path" do
        start_count = User.count
        user = users(:kari)
        perform_login(user)

        expect(session[:user_id]).must_equal user.id
        expect(User.count).must_equal start_count
        must_redirect_to root_path
    end

    it "creates an account for a new user and redirects to the root route" do
      start_count = User.count
      user = User.new(provider: "github", uid: 99999, username: "test_user", email: "test@user.com")
      user.save

      perform_login(user)

      expect(session[:user_id]).must_equal User.last.id
      expect(User.count).must_equal start_count + 1
      must_redirect_to root_path
    end

    it "will handle a request with invalid information" do
      start_count = User.count
      user = User.new(provider: "github", email: "test@user.com")

      perform_login(user)

      expect(User.count).must_equal start_count
      must_redirect_to root_path
    end

    it "logs in an existing user" do
      start_count = User.count
      user = users(:kari)

      perform_login(user)
      must_redirect_to root_path
      session[:user_id].must_equal  user.id

      # Should *not* have created a new user
      User.count.must_equal start_count
    end
  end

  describe "logout" do
    it "will log out a logged in user" do
      start_count = User.count
      user = users(:kari)
      perform_login(user)

      expect(session[:user_id]).must_equal user.id
      delete logout_path

      expect(session[:user_id]).must_be_nil
      expect(User.count).must_equal start_count
      must_redirect_to root_path
    end

    it "will redirect back and give a flash notice if a guest user tries to logout" do
      delete logout_path

      must_redirect_to root_path
      expect(session[:user_id]).must_equal nil
    end
  end

end

