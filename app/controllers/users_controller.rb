# frozen_string_literal: true

# Simple CRUD for friendships
# Probably could have made a separate controller for Friendship?
class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :instantiate

  def index
  end

  def search
    @results = User.search(params)
  end

  def add_friend
    @friendship = Friendship.create(requestor_id: current_user.id, recipient_id: params[:id], status: "pending")
  end

  def accept_request
    friendship = Friendship.find_by(recipient_id: current_user.id, requestor_id: params[:id], status: "pending")
    friendship.update(status: "accepted") if friendship
  end

  def remove_friend
    friendship = Friendship.find_friendship current_user.id, params[:id], "accepted"
    friendship&.destroy
    # @friend = (friendship.requestor_id == current_user.id) ? friendship.recipient : friendship.requestor
    # respond_to(&:turbo_stream)
  end

  def cancel_request
    friendship = Friendship.find_by(requestor_id: current_user.id, recipient_id: params[:id], status: "pending")
    friendship&.destroy
  end

  def show
    @user = User.find_by_id(params[:id])
    if @user
      @friendship = Friendship.find_friendship current_user.id, params[:id]
    else
      render "users/_user_not_found"
    end
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
