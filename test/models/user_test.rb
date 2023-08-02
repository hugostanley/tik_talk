require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'the truth' do
    assert_equal 'test 1', users(:user_one).full_name
  end
end
