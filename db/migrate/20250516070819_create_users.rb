class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      # tはtableのt
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
