class SessionsController < ApplicationController
  
  def new
  end

  def create # POST /login
    user = User.find_by(email: params[:session][:email].downcase) # Dbからメールアドレスで特定
    # &.演算子は obj && obj.method -> obj&.method にできる
    if user&.authenticate(params[:session][:password]) # userが存在するかつ正しいパスワードの場合
      reset_session # ログイン直前に必ずこれを入れることで悪意のある第3者からのセッションIDをリセットできる
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # remember_me - checkboxが、1のときcookiesで永続的なセッションの記憶
                                # 0のとき保存したcookiesを破棄する
      log_in user # sessionHelper 暗号化したユーザーIdの保存
      redirect_to user # redirect_to user_url(user)
    else
      flash.now[:danger] = 'Invalid email/password combination' # flasd.nowはそのあとに新しいリクエストが発生したら消滅する
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    # 複数端末でlogoutしようとすると2つ目でcurent_userがnilになってしまうから -> if文
    log_out if logged_in? 
    redirect_to root_url, status: :see_other
  end

end
