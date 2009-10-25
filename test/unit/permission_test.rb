require 'test_helper'

class PermissionTest < ActiveSupport::TestCase

  should_belong_to :public_key
  should_belong_to :repository 

end
