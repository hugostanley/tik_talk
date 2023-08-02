require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'should not save with empty body' do
    message = Message.new(friendship_id: friendships(:friendship_one).id, sender_id: users(:user_one).id,
                          receiver_id: users(:user_two).id)
    assert_not message.save
  end
end
