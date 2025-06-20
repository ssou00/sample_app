class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index,:edit,:update,:destroy,:following,:followers]
  # onlyオプションでeditとupdateのみに制限
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).page(params[:page])
  end

  def show
    # /users/[:id]
    @user = User.find(params[:id])
    @microposts = @user.microposts.page(params[:page])
    redirect_to root_url and return unless @user.activated == true
    # params -> URLの末尾にidとして情報を渡す(/users/1<-これがparamsで引っ張ってこれる)
    # debugger このメソッドが呼び出された瞬間の状態をコマンドで確認できる
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)# ユーザークラスを作成して 
    if @user.save # ユーザーをdb上にsaveできたら
      @user.send_activation_email # 有効化メールの送信
      flash[:info] = "Please check your email to activate your account." # 通知メッセージの表示
      redirect_to root_url
      
      #reset_session # セキュリティ対策にsessionをリセット
      #log_in @user # log in
      #flash[:success] = "Welcome to the Sample App!"
      #redirect_to @user
      # redirect_to user_url(@user)と同じ
      
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile update"
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url, status: :see_other
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.page(params[:page])
    render 'show_follow'
  end

  def followers
    @titls = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.page(params[:page])
    render 'show_follow'
  end

  private
  # private -> 外部から扱えないようにする
    def user_params
      # params -> POSTリクエスト時に入力されたuserのネストされたハッシュが送られる
      params.require(:user).permit(:name,:email,
                                  :password,:password_confirmation)
      # Strong Parameters -> requireパラメータとpermitパラメータを指定し、requireパラメータがないとエラーとなり、permitパラメータのみが許可されたハッシュを返す
      # :user属性を必須とし、name,email,passwordのみが許可されたハッシュを返す
      # adminをいじれないようにすることでセキュリティを向上
      # userがないとエラーとなる
    end

    # beforeフィルタ

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url, status: :see_other) unless current_user.admin?
    end

end
