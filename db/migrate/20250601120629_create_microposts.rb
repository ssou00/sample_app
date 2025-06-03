class CreateMicroposts < ActiveRecord::Migration[7.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true # reference -> 自動でインデックスと外部キー参照着きのuser_idが追加
      # userとの関連付けができる

      t.timestamps
    end
    add_index :microposts, [:user_id, :created_at]
  end
end
