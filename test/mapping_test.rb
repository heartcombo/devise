require 'test/test_helper'

class Participant < User; end
class Organizer < User; end

class MapTest < ActiveSupport::TestCase

  def setup
    @mappings = Devise.mappings
    Devise.mappings = {}
  end

  def teardown
    Devise.mappings = @mappings
  end

  test 'store options' do
    Devise.map :participant, :to => Participant, :for => :authenticable

    mappings = Devise.mappings
    assert_not mappings.empty?

    assert_equal Participant,      mappings[:participant].to
    assert_equal [:authenticable], mappings[:participant].for
    assert_equal :participants,    mappings[:participant].as
  end

  test 'require :for option' do
    assert_raise ArgumentError do
      Devise.map :participant, :to => Participant
    end
  end

  test 'assert valid keys in options' do
    assert_raise ArgumentError do
      Devise.map :participant, :to => Participant, :for => [:authenticable], :other => 123
    end
  end

  test 'use map name pluralized to :as option if none is given' do
    Devise.map :participant, :for => [:authenticable]
    assert_equal :participants, Devise.mappings[:participant].as
  end

  test 'allows a controller depending on the mapping' do
    Devise.map :participant, :for => [:authenticable, :confirmable]

    assert Devise.mappings[:participant].allows?(:sessions)
    assert Devise.mappings[:participant].allows?(:confirmations)
    assert_not Devise.mappings[:participant].allows?(:passwords)
  end
end
