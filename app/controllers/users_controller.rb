class UsersController < ApplicationController
  def show
    # /users/[:id]
    @user = User.find(params[:id])
    # params -> URLの末尾にidとして情報を渡す(/users/1<-これがparamsで引っ張ってこれる)
    # debugger このメソッドが呼び出された瞬間の状態をコマンドで確認できる
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)# ユーザークラスを作成して 
    if @user.save # ユーザーをdb上にsaveできたら作成できている
      reset_session # セキュリティ対策にsessionをリセット
      log_in @user # log in
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
      # redirect_to user_url(@user)と同じ
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private
  # private -> 外部から扱えないようにする
    def user_params
      # params -> POSTリクエスト時に入力されたuserのネストされたハッシュが送られる
      params.require(:user).permit(:name,:email,
                                  :password,:password_confirmation)
      # Strong Parameters -> requireパラメータとpermitパラメータを指定し、requireパラメータがないとエラーとなり、permitパラメータのみが許可されたハッシュを返す
      # :user属性を必須とし、name,email,passwordのみが許可されたハッシュを返す
      # userがないとエラーとなる
    end
end
