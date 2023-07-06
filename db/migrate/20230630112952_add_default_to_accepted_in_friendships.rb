class AddDefaultToAcceptedInFriendships < ActiveRecord::Migration[7.0]
  def change
    change_column_default :friendships, :accepted, false
  end
end
