class Friendship < ApplicationRecord
  belongs_to :recipient, class_name: 'User'
  belongs_to :requestor, class_name: 'User'
  has_many :messages
  validates :status, inclusion: { in: %w[accepted rejected pending], message: '%<value>s is not a valid status' }

  after_create_commit do
    # OMGGGG
    # WE SUBSCRIBE TO specifc USERES ONLY
    # so the turbo_stream_from should have the user's id as the value instead
    # then we subscribe to that user id, so per create_commit, we are subscribing to two users hence we are able
    # to update the screen of that user realtim BRO
    #
    broadcast_replace_to requestor_id, partial: 'users/sent_request', locals: { request: self, user: recipient },
                                       target: "user_#{recipient_id}"
    broadcast_replace_to recipient_id, partial: 'users/received_request', locals: { request: self, user: requestor },
                                       target: "user_#{requestor_id}"

    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user',
                                                 locals: { friendship: self, user: recipient }, target: "user_#{recipient_id}"

    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: self, user: requestor },
                                                 target: "user_#{requestor_id}"
  end

  after_update_commit do
    broadcast_replace_to requestor_id, partial: 'users/sent_request', locals: { request: self, user: recipient },
                                       target: "user_#{recipient_id}"
    broadcast_replace_to recipient_id, partial: 'users/received_request', locals: { request: self, user: requestor },
                                       target: "user_#{requestor_id}"

    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user',
                                                 locals: { friendship: self, user: recipient }, target: "user_#{recipient_id}"

    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: self, user: requestor },
                                                 target: "user_#{requestor_id}"
  end

  after_destroy_commit do
    broadcast_replace_to 'friendship', partial: 'users/add_friend', locals: { user: recipient }, target: self

    broadcast_replace_to "user_#{requestor_id}_show", partial: 'users/user',
                                                 locals: { friendship: nil, user: recipient }, target: "user_#{recipient_id}"

    broadcast_replace_to "user_#{recipient_id}_show", partial: 'users/user', locals: { friendship: nil, user: requestor },
                                                 target: "user_#{requestor_id}"
  end

  def self.find_friendship(id1, id2, status = nil)
    if status
      Friendship.find_by(recipient_id: id1, requestor_id: id2,
                         status:) || Friendship.find_by(recipient_id: id2, requestor_id: id1,
                                                        status:)
    else
      Friendship.find_by(recipient_id: id1,
                         requestor_id: id2) || Friendship.find_by(recipient_id: id2,
                                                                  requestor_id: id1)
    end
  end
end
