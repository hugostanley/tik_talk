class Message < ApplicationRecord
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  validates :body, presence: true

  after_create_commit do
    broadcast_append_to "friendship_#{friendship_id}_#{receiver_id}_conversation", partial: 'chats/message',
                                                                                   locals: { message: self, user: nil }, target: 'chatbox'
    broadcast_replace_to "friendship_#{friendship_id}_preview", partial: 'chats/sidebar_message_preview',
                                                               locals: { last_message: self, friend: sender }, target: "#{friendship_id}_preview"
  end
end
