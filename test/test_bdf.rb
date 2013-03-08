require 'helper'
require 'bdf'

class TestBdf < Test::Unit::TestCase

  def test_version
    version = Bdf.const_get('VERSION')

    assert !version.empty?, 'should have a VERSION constant'
  end

end
