class SessionsController < ApplicationController
  
  def new # GET /login
    # ログインに必要な入力フォームの表示
  end

  def create # POST /login
    user = User.find_by(email: params[:session][:email].downcase) # Dbからメールアドレスで特定
    # &.演算子は obj && obj.method -> obj&.method にできる
    if user &. authenticate(params[:session][:password])
      if user.activated? # ユーザーが有効化済みの場合 # user&.authenticate(params[:session][:password]) # userが存在するかつ正しいパスワードの場合
        forwarding_url = session[:forwarding_url]
        reset_session # ログイン直前に必ずこれを入れることで悪意のある第3者からのセッションIDをリセットできる
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        # remember_me - checkboxが、1のときcookiesで永続的なセッションの記憶
                                  # 0のとき保存したcookiesを破棄する
        log_in user # sessions Helper 暗号化したユーザーIdの保存
        redirect_to forwarding_url || user # セッションに保存していたurlかそれが存在しないなら、user画面
      else
        message = "Account not activated.  "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination' # flasd.nowはそのあとに新しいリクエストが発生したら消滅する
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy # DELETE /logout
    # 複数端末でlogoutしようとすると2つ目でcurent_userがnilになってしまうから -> if文
    log_out if logged_in? 
    redirect_to root_url, status: :see_other
  end

end
