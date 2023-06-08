class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.string :image_url
      t.string :note
      t.references :user, null: false, foreign_key: true
      t.references :daily_word, null: false, foreign_key: true

      t.timestamps
    end
  end
end
