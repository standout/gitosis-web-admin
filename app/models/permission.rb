class Permission < ActiveRecord::Base

  belongs_to :public_key
  belongs_to :repository

end
