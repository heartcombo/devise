require 'test/test_helper'

class Participant < User; end

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
    assert_equal({:to => Participant, :for => [:authenticable], :as => :participants}, mappings[:participants])
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

  test 'set the first mapping as default' do
    Devise.mappings.default = nil
    assert_nil Devise.mappings.default
    Devise.map :participants, :for => [:authenticable]
    assert_equal :participants, Devise.mappings.default
  end

  test 'map should lookup for the mapping class if no one is given' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal Participant, Devise.mappings[:participants][:to]
  end

  test 'use mapping to :as option if none is given' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal :participants, Devise.mappings[:participants][:as]
  end

  test 'find right mapping to use for routing' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal 'participants', Devise.find_mapping('participants')
  end

  test 'find right mapping to Participant for routing with :as option' do
    Devise.map :participants, :for => [:authenticable], :as => 'usuarios'
    assert_equal 'participants', Devise.find_mapping('usuarios')
  end

  test 'find mapping should return default map in no one is found or empty is given' do
    Devise.map :participants, :for => [:authenticable]
    assert_equal 'participants', Devise.find_mapping('test_drive')
    assert_equal 'participants', Devise.find_mapping(nil)
  end
end
