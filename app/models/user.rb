class User < ApplicationRecord
    attr_accessor :remember_token # 仮想の属性の作成 これで検索かけないからインデックスいらない

    before_save { self.email = email.downcase } # emailを小文字に変換
    # presence(存在性)、length(長さ)の最大の付与
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
    has_secure_password # 色んな要素を追加するメソッド
    # 
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

    # 渡された文字列のハッシュ値を返す -> セキュアなパスワードの作成時に使う
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string,cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64 # base64は64種類の文字からなる長さ22の文字列->確率的にほぼほぼかぶらない
    end

    # 永続的セッションのためにユーザーをデータベースに記憶する
    def remember 
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token)) # 今回はパスワードにアクセスできないのでバリデーションを素通りさせる
                                         # digestでハッシュ化したトークンをdbにupdate
        remember_digest
    end

    # セッションハイジャック防止のためにセッショントークンを返す
    # この記憶ダイジェストを再利用しているのは利便性のため
    def session_token
        remember_digest || remember
    end

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end
end

