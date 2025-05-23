module SessionsHelper
    # 渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id # 渡されたユーザーの暗号化ユーザーIDの作成
        # session[:user_id]でユーザーIDを元通りに取り出せる
    end

    # 現在ログイン中のユーザーを返す
    def current_user
        if session[:user_id] # sessionにユーザーが保存されている場合
            @current_user ||= User.find_by(id: session[:user_id]) # current_userがnilの場合にfind_by
            # current_userになんらかの値があるならcurrent_userを代入(値が変わらない)
        end
    end

    # 現在ログインしているかどうかの論理値を返す
    def logged_in?
        # 現在ログインしている -> current_userがnilじゃない
        !current_user.nil?
    end

    def log_out
        reset_session
        @current_user = nil # current_userに保存されているログインしていたユーザー情報をnilで上書き
    end

end
