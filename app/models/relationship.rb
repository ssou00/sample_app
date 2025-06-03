class Relationship < ApplicationRecord
    belongs_to :follower, class_name: "User" # follower_idがUserクラスをさしていることを明示
    belongs_to :followed, class_name: "User"
    validates :follower_id, presence: true
    validates :followed_id, presence: true
    
end

# active_relationship.follower	フォロワーを返す
# active_relationship.followed	フォローしているユーザーを返す
# user.active_relationships.create(followed_id: other_user.id)	userと紐付けて能動的関係を作成/登録する
# user.active_relationships.create!(followed_id: other_user.id)	userを紐付けて能動的関係を作成/登録する（失敗時にエラーを出力）
# user.active_relationships.build(followed_id: other_user.id)	userと紐付けた新しいRelationshipオブジェクトを返す