require 'test_helper'

class RecordChangesTest < AionTestCase
  def test_default_changes_extractor
    user = UntrackedUser.create!(
      username: 'username',
      password: '1234',
      activated: true,
      activated_at: Time.now,
      status: 'guest'
    )

    user.username = 'username-v-2'
    user.status = 'admin'
    user.activated = false

    expected_changes = {
      'username' => ['username', 'username-v-2'],
      'activated' => [true, false],
      'status' => ['guest', 'admin']
    }

    assert_equal expected_changes, Aion::RecordChanges::Default.new(user).extract
  end

  def test_extractor_returns_default_changes_extractor
    extractor = Aion::RecordChanges.extractor

    assert_equal extractor, Aion::RecordChanges::Default
  end

  def test_extractor_returns_suplied_changes_extractor
    custom_extractor = Class.new

    assert_equal custom_extractor, Aion::RecordChanges.extractor(custom_extractor)
  end
end
