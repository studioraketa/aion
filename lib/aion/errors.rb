module Aion
  class Error < StandardError
  end

  class IrreversibleChangeError < Error
    def message
      'You cannot reverse an initial version'
    end
  end
end
