require 'test_helper'

class RevertTest < AionTestCase
  def user_params(attributes = {})
    {
      username: 'username',
      password: '1234',
      activated: false,
      status: 'guest'
    }.merge(attributes)
  end

  def create_user(params)
    User.create!(params)
  end

  # rubocop:disable Metrics/ParameterLists
  def assert_changeset(user, changeset, version, action, archived, diff)
    assert_equal 'User', changeset.versionable_type
    assert_equal user.id.to_s, changeset.versionable_identifier
    assert_equal 'en', changeset.locale
    assert_equal '', changeset.operator
    assert_equal action, changeset.action
    assert_equal version, changeset.version
    assert_equal archived, changeset.archived
    assert_equal diff, changeset.diff
  end
  # rubocop:enable Metrics/ParameterLists

  def test_revert_to_given_version
    create_params = user_params(activated_at: Time.current)
    user = create_user(create_params)

    user.update!(username: 'new_username')
    user.update!(password: 'new_password')
    user.update!(status: 'admin')

    assert_equal 4, user.versions.count

    changeset = user.versions.find_by(version: 1)
    assert_changeset(
      user,
      changeset,
      1,
      'create',
      false,
      'username' => [nil, create_params[:username]],
      'password' => [nil, create_params[:password]],
      'activated' => [nil, create_params[:activated]],
      'status' => [nil, create_params[:status]],
      'activated_at' => [nil, create_params[:activated_at].utc.iso8601(3).to_s]
    )

    # Check version 2
    changeset = user.versions.find_by(version: 2)
    assert_changeset(
      user,
      changeset,
      2,
      'update',
      false,
      'username' => [create_params[:username], 'new_username']
    )

    # Check version 3
    changeset = user.versions.find_by(version: 3)
    assert_changeset(
      user,
      changeset,
      3,
      'update',
      false,
      'password' => [create_params[:password], 'new_password']
    )

    # Check version 4
    changeset = user.versions.find_by(version: 4)
    assert_changeset(
      user,
      changeset,
      4,
      'update',
      false,
      'status' => [create_params[:status], 'admin']
    )

    user.reload

    assert_equal 'new_username', user.username
    assert_equal 'new_password', user.password
    assert_equal 'admin', user.status

    changeset = user.versions.find_by(version: 1)

    changeset.revert_to

    assert_equal 1, user.versions.count

    user.reload

    assert_equal create_params[:username], user.username
    assert_equal create_params[:password], user.password
    assert_equal create_params[:status], user.status
  end

  def test_revert_given_version
    create_params = user_params(activated_at: Time.current)
    user = create_user(create_params)

    user.update!(username: 'new_username')
    user.update!(password: 'new_password')
    user.update!(status: 'admin')

    assert_equal 4, user.versions.count

    changeset = user.versions.find_by(version: 1)
    assert_changeset(
      user,
      changeset,
      1,
      'create',
      false,
      'username' => [nil, create_params[:username]],
      'password' => [nil, create_params[:password]],
      'activated' => [nil, create_params[:activated]],
      'status' => [nil, create_params[:status]],
      'activated_at' => [nil, create_params[:activated_at].utc.iso8601(3).to_s]
    )

    # Check version 2
    changeset = user.versions.find_by(version: 2)
    assert_changeset(
      user,
      changeset,
      2,
      'update',
      false,
      'username' => [create_params[:username], 'new_username']
    )

    # Check version 3
    changeset = user.versions.find_by(version: 3)
    assert_changeset(
      user,
      changeset,
      3,
      'update',
      false,
      'password' => [create_params[:password], 'new_password']
    )

    # Check version 4
    changeset = user.versions.find_by(version: 4)
    assert_changeset(
      user,
      changeset,
      4,
      'update',
      false,
      'status' => [create_params[:status], 'admin']
    )

    user.reload

    assert_equal 'new_username', user.username
    assert_equal 'new_password', user.password
    assert_equal 'admin', user.status

    changeset = user.versions.find_by(version: 2)

    changeset.revert

    assert_equal 1, user.versions.count

    user.reload

    assert_equal create_params[:username], user.username
    assert_equal create_params[:password], user.password
    assert_equal create_params[:status], user.status
  end

  def test_revert_first_version
    create_params = user_params(activated_at: Time.current)
    user = create_user(create_params)

    user.update!(username: 'new_username')
    user.update!(password: 'new_password')
    user.update!(status: 'admin')

    assert_equal 4, user.versions.count

    changeset = user.versions.find_by(version: 1)
    assert_changeset(
      user,
      changeset,
      1,
      'create',
      false,
      'username' => [nil, create_params[:username]],
      'password' => [nil, create_params[:password]],
      'activated' => [nil, create_params[:activated]],
      'status' => [nil, create_params[:status]],
      'activated_at' => [nil, create_params[:activated_at].utc.iso8601(3).to_s]
    )

    error = assert_raises Aion::IrreversibleChangeError do
      changeset.revert
    end

    assert_equal 'You cannot reverse an initial version', error.message
  end
end
