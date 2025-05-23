class User < ApplicationRecord
    before_save { self.email = email.downcase } # emailを小文字に変換
    # presence(存在性)、length(長さ)の最大の付与
    validates :name, presence: true, length: { maximum: 50 }
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: { maximum: 255 },
                      format: { with: VALID_EMAIL_REGEX },
                      uniqueness: true
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }

    # 渡された文字列のハッシュ値を返す -> セキュアなパスワードの作成時に使う
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
        BCrypt::Password.create(string,cost: cost)
    end

end

