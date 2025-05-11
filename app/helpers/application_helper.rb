module ApplicationHelper  # moduleはインスタンスを持てない、javaのstaticメソッドみたいなもん
    #ページごとに完全なタイトルを返す
    def full_title(page_title = '') # メソッド定義
        base_title = "Ruby on Rails Tutorial Sample App" # 変数の定義
        if page_title.empty?                             # 論理値テスト、分岐
            base_title                                   # 暗黙の戻り値
        else
            "#{page_title} | #{base_title}"              # 文字式の式展開
        end
    end
end
