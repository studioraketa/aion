require 'test_helper'

module Aion
  module Integration
    class UntrackedRecordsTest < AionTestCase
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
        UntrackedUser.create!(params)
      end

      def test_tracks_create_changes
        create_user(user_params)

        assert_equal 0, Aion::Changeset.count
      end

      def test_tracking_update_changes
        user = create_user(user_params)
        user.update!(user_update_params(activated_at: Time.current))

        assert_equal 0, Aion::Changeset.count
      end

      def test_tracking_destroy_changes
        user = create_user(user_params)
        user.destroy!

        assert_equal 0, Aion::Changeset.count
      end
    end
  end
end
