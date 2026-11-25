# frozen_string_literal: true

require File.expand_path("#{File.dirname(__FILE__)}/../../../test/test_helper")

module SecretSanta
  module TestHelpers
    ADMIN_USER_ID = 1
    REGULAR_USER_ID = 2
    SECOND_REGULAR_USER_ID = 3

    def create_player(user_id:, want_to_get: 'Books', dont_want_to_get: 'Socks')
      SecretSanta::Player.create!(
        id: user_id,
        want_to_get: want_to_get,
        dont_want_to_get: dont_want_to_get
      )
    end

    def create_game(name: 'Secret Santa ((Giver_name))', message: 'Gift for ((Receiver_name)): ((Receiver_preferred_gifts)) / Avoid: ((Receiver_avoid_these_gifts))')
      SecretSanta::Game.create!(name: name, message: message)
    end
  end

  class UnitTestCase < ActiveSupport::TestCase
    include SecretSanta::TestHelpers

    fixtures :users, :email_addresses

    def setup
      super
      SecretSanta::Assignment.delete_all
      SecretSanta::Player.delete_all
      SecretSanta::Game.delete_all
    end
  end

  class ControllerTestCase < Redmine::ControllerTest
    include SecretSanta::TestHelpers

    fixtures :users, :email_addresses

    def setup
      super
      SecretSanta::Assignment.delete_all
      SecretSanta::Player.delete_all
      SecretSanta::Game.delete_all
      User.current = nil
    end

    def login_as(user_id)
      @request.session[:user_id] = user_id
      User.current = User.find(user_id)
    end
  end
end
