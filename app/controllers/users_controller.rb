class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :edit, :update ]
  before_action :ensure_current_user, only: [ :edit, :update ]

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path(@user.username), notice: "Profile updated successfully."
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def ensure_current_user
    redirect_to root_path unless @user == current_user
  end

  def user_params
    params.require(:user).permit(:bio)
  end
end
