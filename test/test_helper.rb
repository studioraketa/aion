$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)

require "aion"
require 'minitest/autorun'
require 'database_helper'

class AionTestCase < Minitest::Test
  def teardown
    truncate_db
  end
end
