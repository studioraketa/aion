class User < ApplicationRecord
  self.table_name = 'users'

  aion_track_changes except: :password
end
