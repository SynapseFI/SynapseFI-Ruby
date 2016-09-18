require 'test_helper'

class VersionTest < Minitest::Test
  def test_it_has_a_version_number
    refute_nil SynapsePayRest::VERSION
  end
end