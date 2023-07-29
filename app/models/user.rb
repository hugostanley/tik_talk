class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable,
    :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :sent_friendships, class_name: "Friendship", foreign_key: "requestor_id"
  has_many :received_friendships, class_name: "Friendship", foreign_key: "recipient_id"

  def incoming_friend_requests
    # OMG OMG OMG
    # THE .includes is basically like a POPULATE in mongodb
    # which means all firendships you can call a Friendship1.requestor ?!!!!!
    # THIS IS GREAT
    # so friendship.requestor already exists, difference is,
    # the friendships array will already include the requestor,
    # ITS eager loaded
    friendships = received_friendships.where(status: "pending")
    return friendships.includes(:requestor) if friendships.any?
  end

  def sent_friend_requests
    friendships = sent_friendships.where(status: "pending")
    return friendships.includes(:recipient) if friendships.any?
  end

  def friends
    received_friends = received_friendships.where(status: "accepted").map(&:requestor)
    sent_friends = sent_friendships.where(status: "accepted").map(&:recipient)
    (received_friends + sent_friends).sort
  end

  def accepted_friendships
    received_friends = received_friendships.where(status: "accepted")
    sent_friends = sent_friendships.where(status: "accepted")
    (received_friends + sent_friends).sort
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
