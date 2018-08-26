require 'active_record'

require 'aion/version'
require 'aion/revert'
require 'aion/diff'
require 'aion/errors'
require 'aion/changeset'
require 'aion/record_changes'
require 'aion/create_changeset'
require 'aion/controller_around_filter'
require 'aion/tracking'

module Aion
  class << self
    attr_reader :controller_statistics

    def request_store
      Thread.current[:aion_store] ||= {}
    end

    def request_info_collector
      ControllerAroundFilter
    end

    def controller_statistics=(values)
      @controller_statistics = Array(values)
    end

    def config
      yield(self)
    end
  end
end

Aion.controller_statistics = %i[request_uuid operator]

class ActiveRecord::Base
  include Aion::Tracking
end
