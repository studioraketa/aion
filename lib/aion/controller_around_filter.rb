module Aion
  module ControllerAroundFilter
    class << self
      def around(controller)
        info = controller.aion_info

        Aion.controller_statistics.each do |attribute|
          Aion.request_store[attribute] = info.fetch(attribute)
        end

        yield
      ensure
        Aion.request_store.clear
      end
    end
  end
end
