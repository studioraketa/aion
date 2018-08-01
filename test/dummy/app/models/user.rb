class User < ApplicationRecord
  enum :status, {created: 0, in_use: 1, suspended: 2}
end
