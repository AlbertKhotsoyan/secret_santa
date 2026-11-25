# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SecretSantaControllerTest < SecretSanta::ControllerTestCase
  NEW_PLAYER_LINK_SELECTOR = 'a[href="/secret_santa_players/new"]'
  NEW_GAME_LINK_SELECTOR = 'a[href="/secret_santa_games/new"]'

  # SPEC: docs/spec/01-player-registration.md (FR-001)
  test 'redirects unauthenticated user to login page' do
    get :index

    assert_response :redirect
  end

  # SPEC: docs/spec/01-player-registration.md (FR-003, FR-004, FR-006)
  # SPEC: docs/spec/02-game-management-and-draw.md (FR-101)
  test 'renders participants list and registration button for regular user without exposing games or gift preferences' do
    secret_preference = 'UltraSecretGiftWish'
    create_player(user_id: ADMIN_USER_ID, want_to_get: secret_preference, dont_want_to_get: 'SecretAvoidItem')
    create_game(name: 'Holiday Exchange')
    login_as(REGULAR_USER_ID)

    get :index

    assert_response :success
    assert_select NEW_PLAYER_LINK_SELECTOR, 1
    assert_select NEW_GAME_LINK_SELECTOR, 0
    assert_not_includes @response.body, secret_preference
  end

  # SPEC: docs/spec/01-player-registration.md (FR-004)
  # SPEC: docs/spec/02-game-management-and-draw.md (FR-101, FR-102)
  test 'renders games section for administrator and hides registration prompt when already registered' do
    create_player(user_id: ADMIN_USER_ID)
    game = create_game(name: 'Admin Holiday Game')
    login_as(ADMIN_USER_ID)

    get :index

    assert_response :success
    assert_select NEW_GAME_LINK_SELECTOR, 1
    assert_select NEW_PLAYER_LINK_SELECTOR, 0
    assert_includes @response.body, game.name
  end
end
