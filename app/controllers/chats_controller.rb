class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :instantiate

  def index; end

  # Method for the actual chatbox
  def show
    @friendship = Friendship.find params[:id]

    # Since the current_user's friend in the friendship model could either be the recipient or requestor,
    # a conditional checking is done
    @friend = @friendship.requestor.id == current_user.id ? @friendship.recipient : @friendship.requestor

    # Get all the messages of that friendship and order by the creation meaning latest creation goes last
    @messages = @friendship.messages.order(:created_at)
    @message = Message.new

    # TODO: refactor
    # Feature for read receipts
    # Get all messages where read_receipt is equal to nil meaning, unread messages from
    # the Friend and not from the current_user
    unread = @messages.where(read_receipt: nil).where.not(sender_id: current_user.id)

    # if there's any, it is updated with Time.now
    #
    # Whenever the chatbox is opened, this is ran
    unread.update_all(read_receipt: Time.now) if unread.any?
  end

  def create
    @message = Message.new(new_message_params)

    respond_to do |format|
      # looks for a turbo_stream template
      #
      # located at: views/chats/create.turbo_stream.erb
      format.turbo_stream if @message.save
    end
  end

  # TODO: currently not working
  # error with the format
  # def destroy
  #   message = Message.find(params[:id])
  #   message&.destroy
  #
  #   respond_to do |format|
  #     format.turbo_stream
  #   end
  # end

  private

  def instantiate
    @friends = current_user.accepted_friendships
  end

  def destroy_message
    params.permit(:id, :friendship_id)
  end

  def new_message_params
    params.require(:message).permit(:sender_id, :receiver_id, :body, :friendship_id)
  end
end
