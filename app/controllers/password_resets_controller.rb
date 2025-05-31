class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # 

  def new
  end

  def create # パスワードの再設定
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user # user見つけた場合
      @user.create_reset_digest # digestつくって
      @user.send_password_reset_email # 作ったtokenのURlが記載されているメールを送る
      flash[:info] = "Email sent password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit

  end

  def update
    if params[:user][:password].empty? # passwordがからの時にerrorを追加する
      @user.errors.add(:password, "can't be empty")
      render 'edit',  status: :unprocessable_entity
    elsif @user.update(user_params) # 新しいpasswordが正しかったら更新
      reset_session
      log_in @user
      @user.update_attribute(:reset_digest, nil) # 使用後にreset_digestをnilにすることで次に同じページから再設定することを防ぐ
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity # 失敗させ元の画面へ
    end
  end


  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def get_user
      @user = User.find_by(email: params[:email])
    end

    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end

end
