class User < ApplicationRecord
    attr_accessor :remember_token, :activation_token
    # 仮想の属性の作成 これで検索かけないからインデックスいらない
    before_save   :downcase_email # ユーザー情報のsave前にemailを小文字に変換
    before_create :create_activation_digest # ユーザーが作成される前に有効か手順を挟む

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
    def authenticated?(attribute,token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    end

    # ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end

    # アカウントの有効化
    def activate
        update_columns(activated: true, activated_at: Time.zone.now)
        # update_attribute(:activated, true)
        # update_attribute(:activated_at, Time.zone.now)
    end

    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    private

        #メールアドレスをすべて小文字に
        def downcase_email
            self.email.downcase!
        end

        # 有効化トークンとダイジェストを作成、代入
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end

end

