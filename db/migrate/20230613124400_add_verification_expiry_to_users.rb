class AddVerificationExpiryToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :verification_expiry, :datetime
  end
end
