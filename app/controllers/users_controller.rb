class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash["uid"], provider: auth_hash["provider"])
    if user
      flash[:status] = :success
      flash[:result_text] = "Welcome back, #{user.username}!"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Logged in as #{user.username}."
      else
        flash[:status] = :error
        flash[:result_text] = "Sorry, could not create new account #{user.errors.messages}"
        return redirect_to root_path
      end
    end

    session[:user_id] = user.id
    return redirect_to root_path
  end

  def login_form
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
