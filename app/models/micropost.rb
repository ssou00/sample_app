class Micropost < ApplicationRecord
  belongs_to :user # userに属している->userに紐づけ
  has_one_attached :image do |attachable| # active_storageのimageに1つにつき1つだけ添付
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  # has_many_attachedで複数ファイルを添付可能
  default_scope -> { order(created_at: :desc) } # order -> 順番を指定、DESC -> 降順に
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png],
                                    message: "must be a valid image format" },
                    size:         { less_than: 5.megabytes,
                                    message:   "should be less than 5MB" }

end
