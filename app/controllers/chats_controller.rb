class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :instantiate

  def index; end

  def show
    @friendship = Friendship.find params[:id]
    @friend = @friendship.requestor.id == current_user.id ? @friendship.recipient : @friendship.requestor
    @messages = @friendship.messages.order(:created_at)
    @message = Message.new
    unread = @messages.where(read_receipt: nil).where.not(sender_id: current_user.id)
    unread.update_all(read_receipt: Time.now) if unread.any?
  end

  def create
    @message = Message.new(new_message_params)

    respond_to do |format|
      format.turbo_stream if @message.save
    end
  end

  private

  def instantiate
    @friends = current_user.accepted_friendships
  end

  def new_message_params
    params.require(:message).permit(:sender_id, :receiver_id, :body, :friendship_id)
  end
end
