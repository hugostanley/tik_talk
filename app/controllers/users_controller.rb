class UsersController < ApplicationController
  before_action :instantiate

  def index
  end

  def search
    @results = User.search(params)
  end

  def add_friend
    @friendship = Friendship.new(requestor_id: current_user.id, recipient_id: params[:id], status: "pending")
    @friendship.save

  end

  def accept_request
    friendship = Friendship.find_by(recipient_id: current_user.id, requestor_id: params[:id], status: "pending")

    friendship.update(status: "accepted") if friendship
  end

  def remove_friend
    friendship = Friendship.find_friendship current_user.id, params[:id], "accepted"

    friendship&.destroy
  end

  def cancel_request
    friendship = Friendship.find_by(requestor_id: current_user.id, recipient_id: params[:id], status: "pending")
    friendship&.destroy
  end

  def show
    @user = User.find(params[:id])
    @friendship = Friendship.find_friendship current_user.id, params[:id]

    # add an error handling if user is not exisiting
  end

  private

  def instantiate
    @users = User.where.not(id: current_user.id)
    @incoming_friend_requests = current_user.incoming_friend_requests
    @sent_friend_requests = current_user.sent_friend_requests
    @friends = current_user.friends
    @current_user = User.find(current_user.id)
  end
end
