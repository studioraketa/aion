require 'test_helper'

class RecordChanges::Test < ActiveSupport::TestCase
  test 'default behaviour test' do
    user = User.create!(username: 'username', status: 'created')

    user.username = 'new_username'
    user.status = 'in_use'

    expected_result = {'username' => ['username', 'new_username'], 'status' => ['created', 'in_use']}
    result = Aion::RecordChanges::Default.new(user).extract

    assert_equal expected_result, result
  end
end
