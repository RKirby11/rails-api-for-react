class AddEmailVerificationToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :verified, :boolean
    add_column :users, :verification_token, :string
    add_index :users, :verification_token
  end
end
