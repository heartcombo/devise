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
    Devise.map :participants, :to => Participant, :for => [:authenticable]
    mappings = Devise.mappings
    assert_not mappings.empty?
    assert_equal Participant, mappings[:participant].to
    assert_equal [:authenticable], mappings[:participant].for
    assert_equal 'participants', mappings[:participant].as
  end

  test 'require :for option' do
    assert_raise ArgumentError do
      Devise.map :participants, :to => Participant
    end
  end

  test 'assert valid keys in options' do
    assert_raise ArgumentError do
      Devise.map :participants, :to => Participant, :for => [:authenticable], :other => 123
    end
  end

  test 'singularize map' do
    Devise.map :participants, :for => [:authenticable]
    assert_not_nil Devise.mappings[:participant]
  end

  test 'use map name pluralized to :as option if none is given' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal 'participants', Devise.mappings[:participant][:as]
  end

  test 'map should lookup for the mapping class if no one is given' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal Participant, Devise.mappings[:participant][:to]
  end

  test 'find right mapping to use for routing' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal :participant, Devise.find_mapping('participants').resource
  end

  test 'find right mapping to Participant for routing with :as option' do
    Devise.map :participants, :for => [:authenticable], :as => 'usuarios'
    assert_equal :participant, Devise.find_mapping('usuarios').resource
  end

  test 'find mapping receiving a path should split it' do
    Devise.map :participants, :for => [:authenticable]
    Devise.map :organizer, :for => [:authenticable]
    assert_equal :organizer, Devise.find_mapping('organizer').resource
    assert_equal :organizer, Devise.find_mapping('/organizers/new').resource
  end

  test 'find resource name based on mapping' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal 'participant', Devise.resource_name('participants')
  end

  test 'find resource class based on mapping' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal Participant, Devise.resource_class('participants')
    Devise.map :organizers, :for => [:authenticable]
    assert_equal Organizer, Devise.resource_class('organizers')
  end
end
