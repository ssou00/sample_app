class ApplicationController < ActionController::Base
    include SessionsHelper

    private

        # ログイン済みユーザーかどうか確認
        def logged_in_user
            unless logged_in? # ログインされていない場合
                store_location
                flash[:danger] = "Please log in." # メッセージの表示
                redirect_to login_url, status: :see_other # 
            end
        end

end
