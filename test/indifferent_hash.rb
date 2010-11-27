require 'test_helper'

class IndifferentHashTest < ActiveSupport::TestCase
  setup do
    @hash = Devise::IndifferentHash.new
  end

  test "it overwrites getter and setter" do
    @hash[:foo] = "bar"
    assert_equal "bar", @hash["foo"]
    assert_equal "bar", @hash[:foo]

    @hash["foo"] = "baz"
    assert_equal "baz", @hash["foo"]
    assert_equal "baz", @hash[:foo]
  end

  test "it overwrites update" do
    @hash.update :foo => "bar"
    assert_equal "bar", @hash["foo"]
    assert_equal "bar", @hash[:foo]

    @hash.update "foo" => "baz"
    assert_equal "baz", @hash["foo"]
    assert_equal "baz", @hash[:foo]
  end

  test "it returns a Hash on to_hash" do
    @hash[:foo] = "bar"
    assert_equal Hash["foo", "bar"], @hash.to_hash
    assert_kind_of Hash, @hash.to_hash
  end
end if defined?(Devise::IndifferentHash)