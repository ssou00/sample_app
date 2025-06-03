class User < ApplicationRecord
    has_many :microposts, dependent: :destroy # micropostの集合を持っている
    # active_relationship -> 能動的relationship、このユーザーからfollowしに行っているリスト
    has_many :active_relationships, class_name: "Relationship", # クラスの名前を指定
                                    foreign_key: "follower_id", # 外部キーは本来"<class>_id"という名前だが今回は"follower_id"だからここで指定 この外部キーとこのユーザーidを参照してデータを持ってくる
                                    dependent:  :destroy # dependent: :destroy -> ユーザーが削除されたらマイクロポストも削除
    # passive -> 受動的relationship、このユーザーがfollowされたリスト
    has_many :passive_relationships, class_name: "Relationship",
                                    foreign_key: "followed_id",
                                    dependent: :destroy
    # through: でactive_relationshipでrelationshipモデルを通ってfollowingをたくさん持っている、souce: でfollowing配列の出所(中身)がfollowedなのを明示
    has_many :following, through: :active_relationships, source: :followed 
    has_many :followers, through: :passive_relationships, source: :follower # 上と同様に逆の関係を定義
    attr_accessor :remember_token, :activation_token, :reset_token
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

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token),reset_sent_at: Time.zone.now)
    end

    # パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # 試作feed
    def feed
        # SQLのサブセレクトを文字列として格納し使う
        following_ids = "SELECT followed_id FROM relationships
                         WHERE  follower_id = :user_id"
        # クエリに代入する前に?にidがエスケープされるためセキュリティ上よい
        # IN でidの集合を扱える
        # user.following_ids -> userのfollowing.map(&:id)であり、followingのユーザーの配列をidの配列に変換
        # rails側でフォローしているユーザーidの集合を取得すると処理に時間がかかるから、DB側で集合の処理をする
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", follow_ids: following_ids, user_id: id)
                # micropostひとつごとに毎回DBにクエリをし、ユーザーを取得していたが、includesでそのクエリを一つに
                 .includes(:user, image_attachment: :blob)
    end

    # ユーザーをフォロー
    def follow(other_user)
        following << other_user unless self == other_user
    end

    # ユーザーをフォロー解除
    def unfollow(other_user)
        following.delete(other_user)
    end
    
    # 現在のユーザーがほかのユーザーをフォローしていればtrue
    def following?(other_user)
        following.include?(other_user)
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

