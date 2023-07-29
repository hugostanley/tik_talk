class AddFriendshipToMessage < ActiveRecord::Migration[7.0]
  def change
    add_reference :messages, :friendship, null: false, foreign_key: true
  end
end
