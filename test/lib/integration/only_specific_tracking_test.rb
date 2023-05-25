require 'test_helper'

module Aion
  module Integration
    class OnlySpecificTrackingTest < AionTestCase
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
        UserOnlyUserName.create!(params)
      end

      def test_tracks_create_changes
        params = user_params(activated_at: Time.current)

        count_before = Aion::Changeset.count
        user = create_user(params)
        count_after = Aion::Changeset.count

        changeset = user.versions.first

        assert_equal 1, user.versions.count
        assert_equal 1, count_after - count_before

        assert_equal 'UserOnlyUserName', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'create', changeset.action
        assert_equal 1, changeset.version
        assert_equal false, changeset.archived
        assert_equal({ 'username' => [nil, params[:username]] }, changeset.diff)
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

        assert_equal 'UserOnlyUserName', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'update', changeset.action
        assert_equal 2, changeset.version
        assert_equal false, changeset.archived
        assert_equal(
          { 'username' => [create_params[:username], update_params[:username]] },
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

        assert_equal 'UserOnlyUserName', changeset.versionable_type
        assert_equal user.id.to_s, changeset.versionable_identifier
        assert_equal 'en', changeset.locale
        assert_equal '', changeset.operator
        assert_equal 'destroy', changeset.action
        assert_equal 2, changeset.version
        assert_equal true, changeset.archived
        assert_equal(
          { 'username' => [params[:username], nil] },
          changeset.diff
        )
      end
    end
  end
end
