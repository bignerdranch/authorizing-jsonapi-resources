class CreateVideoGames < ActiveRecord::Migration[5.0]
  def change
    create_table :video_games do |t|
      t.references :user, foreign_key: true, null: false
      t.string :title, null: false

      t.timestamps
    end
  end
end
