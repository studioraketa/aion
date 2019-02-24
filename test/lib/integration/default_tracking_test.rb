require 'test_helper'

module Aion
  module Integration
    class DefaultTrackingTest < AionTestCase
      def user_params(attributes = {})
        {
          username: 'username',
          password: '1234',
          activated: false,
          status: 'guest'
        }.merge(attributes)
      end

      def user_update_params(attributes = {})
        {
          username: 'new_username',
          password: '4321',
          activated: true,
          activated_at: Time.current,
          status: 'admin'
        }.merge(attributes)
      end

      def create_user(params)
        User.create!(params)
      end

      def test_tracks_create_changes
        params = user_params(activated_at: Time.current)

        count_before = Aion::Changeset.count
        user = create_user(params)
        count_after = Aion::Changeset.count

        changeset = user.versions.first

        assert_equal 1, user.versions.count
        assert_equal 1, count_after - count_before

        assert_equal 'User', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'create', changeset.action
        assert_equal 1, changeset.version
        assert_equal false, changeset.archived
        assert_equal(
          {
            'username' => [nil, params[:username]],
            'password' => [nil, params[:password]],
            'activated' => [nil, params[:activated]],
            'status' => [nil, params[:status]],
            'activated_at' => [nil, params[:activated_at].utc.iso8601(3).to_s]
          },
          changeset.diff
        )
      end

      def test_tracking_update_changes
        create_params = user_params
        user = create_user(create_params)
        update_params = user_update_params(activated_at: Time.current)

        count_before = Aion::Changeset.count
        user.update!(update_params)
        count_after = Aion::Changeset.count

        changeset = user.versions.last

        assert_equal 2, user.versions.count
        assert_equal 1, count_after - count_before

        assert_equal 'User', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'update', changeset.action
        assert_equal 2, changeset.version
        assert_equal false, changeset.archived
        assert_equal(
          {
            'username' => [create_params[:username], update_params[:username]],
            'password' => [create_params[:password], update_params[:password]],
            'activated' => [create_params[:activated], update_params[:activated]],
            'status' => [create_params[:status], update_params[:status]],
            'activated_at' => [nil, update_params[:activated_at].iso8601(3).to_s]
          },
          changeset.diff
        )
      end

      def test_tracking_destroy_changes
        params = user_params(activated_at: Time.current)
        user = create_user(params)

        count_before = Aion::Changeset.count
        user.destroy!
        count_after = Aion::Changeset.count

        changeset = user.versions.last

        assert_equal 2, user.versions.count
        assert_equal 1, count_after - count_before

        assert_equal 'User', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'destroy', changeset.action
        assert_equal 2, changeset.version
        assert_equal true, changeset.archived
        assert_equal(
          {
            'username' => [params[:username], nil],
            'password' => [params[:password], nil],
            'activated' => [params[:activated], nil],
            'status' => [params[:status], nil],
            'activated_at' => [params[:activated_at].utc.iso8601(3).to_s, nil]
          },
          changeset.diff
        )
      end
    end
  end
end
