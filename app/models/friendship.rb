class Friendship < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :requestor, class_name: 'User'
  has_many :messages, dependent: :destroy
  validates :status, inclusion: { in: %w[accepted rejected pending], message: '%<value>s is not a valid status' }

  # Main idea: 
  # Whenever a current_user visits users/show page, the user then subscribes to a websocket
  # that is specific to the current_user's id
  #
  # see: views/users/show.html.erb
  #
  # Then the page showing the other user's profile has
  # a div id specific to that user's profile
  #
  # see: views/users/_user.html.erb
  #
  # Process:
  # 1. When changes are made (create, update, destroy)
  # 2. Invoke necessary callbacks (after_create_commit, after_update_commit, after_destroy_commit) 
  # 3. broadcast to the user specific turbo_stream_from connection
  # 4. target the div with id specific to user's profile
  #
  # Ex.
  # When current_user visits user/2 profile, 
  # a turbo_stream_from with current_user's id is opened
  # and a div with the user/2 id
  #
  # Once current_user clicks a button, the callback method subscribes to the turbo_stream_from opened by current user
  # and even the target user. 
  #
  # This allows realtime updates to both sides
  after_create_commit do
    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: self, user: requestor },
                                                      target: "user_#{requestor_id}_profile"

    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user', locals: { friendship: self, user: recipient },
                                                      target: "user_#{recipient_id}_profile"
  end

  after_update_commit do
    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: self, user: requestor },
                                                      target: "user_#{requestor_id}_profile"

    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user', locals: { friendship: self, user: recipient },
                                                      target: "user_#{recipient_id}_profile"
  end

  after_destroy_commit do
    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user',
                                                      locals: { friendship: nil, user: recipient }, target: "user_#{recipient_id}_profile"

    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: nil, user: requestor },
                                                      target: "user_#{requestor_id}_profile"
  end

  def self.find_friendship(id1, id2, status = nil)
    if status
      Friendship.find_by(recipient_id: id1, requestor_id: id2,
                         status:) || Friendship.find_by(recipient_id: id2, requestor_id: id1,
                                                        status:)
    else
      Friendship.find_by(recipient_id: id1,
                         requestor_id: id2) ||
        Friendship.find_by(recipient_id: id2, requestor_id: id1)
    end
  end
end
