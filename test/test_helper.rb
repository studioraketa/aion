require 'simplecov'

SimpleCov.start do
  add_filter(/.test\.rb/)
  add_filter(%r{test\/database_helper\.rb})
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'aion'
require 'minitest/autorun'
require 'database_helper'

class AionTestCase < Minitest::Test
  def teardown
    truncate_db
  end
end
