class CreateSubmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :submissions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :image_url
      t.string :note
      t.datetime :date

      t.timestamps
    end
  end
end
