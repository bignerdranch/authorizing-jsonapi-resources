class CreateFollows < ActiveRecord::Migration[5.0]
  def change
    create_table :follows do |t|
      t.references :follower, foreign_key: {to_table: :users}
      t.references :followed, foreign_key: {to_table: :users}

      t.timestamps
    end
    add_index :follows, [:follower_id, :followed_id], unique: true
  end
end
