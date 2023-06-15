class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.integer :requester
      t.integer :responder
      t.boolean :accepted

      t.timestamps
    end
  end
end
