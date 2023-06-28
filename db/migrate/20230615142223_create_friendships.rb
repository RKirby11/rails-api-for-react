class CreateFriendships < ActiveRecord::Migration[7.0]
  def change
    create_table :friendships do |t|
      t.integer :requester_id
      t.integer :responder_id
      t.boolean :accepted

      t.timestamps
    end
  end
end
