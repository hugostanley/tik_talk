# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]

  # has_many :sent_friendships allows a = UserInstance.sent_friendships
  #
  # It does an SQL query like this:
  #
  # SELECT * from Friendships where requestor_id = user.id
  has_many :sent_friendships, class_name: 'Friendship', foreign_key: 'requestor_id' # standard:disable Style/StringLiterals
  has_many :received_friendships, class_name: "Friendship", foreign_key: "recipient_id"
  has_one :requestor, class_name: "User", foreign_key: "requestor_id"
  has_one :recipient, class_name: "User", foreign_key: "recipient_id"

  # Method that will return a userInstance's friendship with another user
  #
  # It does an SQL query like this:
  #
  # SELECT * from Friendships where requestor_id= 1 and recipient_id = 2 and status = 'accepted'
  # OR requestor_id = 2 and recipient_id = 1 and status = 'accepted'
  def friendship(user_id)
    Friendship.where(requestor_id: id, recipient_id: user_id,
      status: "accepted").or(Friendship.where(requestor_id: user_id,
        recipient_id: id, status: "accepted")).first
  end

  # Method to populate Friendships[] with requestor
  #
  # The .includes is basically like a POPULATE in mongodb
  #
  # FriendshipInstance.requestor already exists, difference is,
  # the friendships array will already include the requestor,
  # so there's no need to query every #requestor call
  # It's eager loaded
  def incoming_friend_requests
    friendships = received_friendships.where(status: "pending")
    return friendships.includes(:requestor) if friendships.any?
  end

  # Similar to incoming_friend_requests
  def sent_friend_requests
    friendships = sent_friendships.where(status: "pending")
    return friendships.includes(:recipient) if friendships.any?
  end

  def accepted_incoming_requests
    friendships = received_friendships.where(status: "accepted")
    return friendships.includes(:requestor) if friendships.any?
  end

  def accepted_sent_requests
    friendships = sent_friend_requests.where(status: "accepted")
    return friendships.includes(:recipient) if friendships.any?
  end

  def self.search(params)
    if params[:query].blank?
      all
    else
      where(
        "full_name LIKE ? OR email LIKE ?", "%#{sanitize_sql_like(params[:query])}%", "%#{sanitize_sql_like(params[:query])}%"
      )
    end
  end

  # the map(&:requestor) method basically does a map and returns the requestor object
  def friends
    received_friends = accepted_incoming_requests.map(&:requestor)
    sent_friends = accepted_sent_requests.map(&:recipient)
    (received_friends + sent_friends).sort
  end

  def accepted_friendships
    (accepted_sent_requests + accepted_incoming_requests).sort
  end

  def friend?(user)
    friends.include?(user)
  end

  def self.from_omniauth(auth)
    user = User.where(email: auth.info.email).first

    user ||= User.create!(email: auth.info.email, password: Devise.friendly_token[0, 20],
      full_name: auth.info.name,
      avatar_url: auth.info.image, provider: auth.provider, uid: auth.uid)
    user
  end
end
