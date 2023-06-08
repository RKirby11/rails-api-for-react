class CreateDailyWords < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_words do |t|
      t.string :word
      t.datetime :date

      t.timestamps
    end
  end
end
