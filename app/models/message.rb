class Message < ApplicationRecord
  include ActionView::Helpers::DateHelper
  # Active Record's belongs_to method expects a foreign_key in your column with the first argument provided
  # This case it expects a sender_id reference column
  # As well as the receiver_id column since belongs_to is called twice
  #
  # Although the symbol is :sender and not :sender_id, the purpose of that is so that you can call a #sender
  # on a Message instance and it will use the sender_id as reference
  #
  # the class_name option is to identify to which table is this being referenced from.
  # Because by default, rails MIGHT look for the sender table
  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'
  validates :body, presence: true

  # Callback function that runs whenever a new message has been created with Message.create
  after_create_commit do
    # Subscribe to: "friendship_#{friendship_id}_#{receiver_id}_conversation"
    #   ex: "friendship_101_2_conversation"
    #     located at: views/chats/show.html.erb
    #
    # Target: 'chatbox'
    #   located at: views/chats/show.html.erb
    #
    # When new message is sent, turbo_steam broadcasts to the receiver's turbo_stream_from tag
    # and updates the receiver's message list with the newly created message.
    #
    # This allows the receiver to receive the message in real time.
    #
    # A different method is done for updating the message list of the sender (current_user).
    #
    # See: controllers/chats_controller.rb#create
    broadcast_append_later_to "friendship_#{friendship_id}_#{receiver_id}_conversation", partial: 'chats/message',
                                                                                         locals: { message: self, user: nil }, target: 'chatbox'
    # Subscribe to: "friendship_#{friendship_id}_preview"
    #   ex: "friendship_1_preview"
    #     located at: views/chats/_friend_sidebar.html.erb
    #
    # Target: "#{friendship_id}_preview"
    #   ex: "1_preview"
    #     located at: views/chats/_sidebar_message_preview.html.erb
    #
    # This turbo_stream broadcast is to show realtime latest message update on the chats#index page
    broadcast_replace_later_to "friendship_#{friendship_id}_preview", partial: 'chats/sidebar_message_preview',
                                                                      locals: { last_message: self, friend: sender }, target: "#{friendship_id}_preview"
  end

  # Commented out as it is not working
  # error is not here, but rather in the controller
  after_destroy_commit do
    broadcast_remove_to "friendship_#{friendship_id}_#{receiver_id}_conversation",
                        target: "friendship_#{friendship_id}_message_#{id}"
    # broadcast_remove_to "friendship_#{friendship_id}_#{sender_id}_conversation",
    #                     target: "friendship_#{friendship_id}_message_#{id}"
  end

  # Commented out as it is unused
  #
  # Use as reference, distance_of_time_in_words is a builtin rails helper
  #
  # Returns something like "2 minutes"
  #
  # Take not of the module include above
  # def time_from_now
  #  distance_of_time_in_words(created_at, Time.now)
  # end
end
