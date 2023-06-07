class AddWordToSubmissions < ActiveRecord::Migration[7.0]
  def change
    add_column :submissions, :word, :string
  end
end
