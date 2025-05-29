module SessionsHelper
    # 渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id # 渡されたユーザーの暗号化ユーザーIDの作成
        # session[:user_id]でユーザーIDを元通りに取り出せる
        # セッションリプレイ攻撃から保護する
        # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
        session[:session_token] = user.session_token
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する
    def remember(user) # ログインするたびに毎回tokenが更新される
        user.remember # tokenを作成し、ハッシュ化したremember_digestをdbに保存
        cookies.permanent.encrypted[:user_id] = user.id # 暗号化したユーザーIDをcookiesに永続的に保存
        cookies.permanent[:remember_token] = user.remember_token # tokenをcookiesに保存
    end

    # 現在ログイン中のユーザーを返す
    def current_user
        if (user_id = session[:user_id]) # sessionにユーザーが保存されている場合
            user = User.find_by(id: user_id)
            if user && session[:session_token] == user.session_token
                @current_user = user
            end
        elsif (user_id = cookies.encrypted[:user_id]) # cookiesに暗号化したuser_idが存在する場合
            user = User.find_by(id: user_id) # user_idが一致したuserを持ってくる
            if user && user.authenticated?(:remember, cookies[:remember_token]) #userが存在する かつ cookiesのremember_tokenがハッシュ化されたremember_digestと一致する場合
                log_in user
                @current_user = user
            end
        end
    end

    # 渡されたユーザーがカレントユーザーであればtrueを返す
    def current_user?(user)
        user && user == current_user
    end

    # 現在ログインしているかどうかの論理値を返す
    def logged_in?
        # 現在ログインしている -> current_userがnilじゃない
        !current_user.nil?
    end

    # 永続的セッションを破棄する
    # remember_digestを破棄する
    # cookiesからも破棄する
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    def log_out
        forget(current_user) # db、cookiesからの破棄
        reset_session 
        @current_user = nil # current_userに保存されているログインしていたユーザー情報をnilで上書き
    end

    # アクセスしようとしたURLを保存する
    def store_location
        session[:forwarding_url] = request.original_url if request.get?
                                  #リクエスト先のURLを取得、getリクエストしたときのみ
    end
end
