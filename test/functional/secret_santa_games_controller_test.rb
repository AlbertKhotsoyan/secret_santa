# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SecretSantaGamesControllerTest < SecretSanta::ControllerTestCase
  MISSING_GAME_ID = 999_999
  UPDATED_GAME_NAME = 'Updated Holiday Game'

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-101)
  test 'redirects non-administrator user away from all game actions' do
    game = create_game
    login_as(REGULAR_USER_ID)

    get :new

    assert_redirected_to secret_santa_path

    get :show, params: {id: game.id}

    assert_redirected_to secret_santa_path

    post :draw, params: {id: game.id}

    assert_redirected_to secret_santa_path

    post :send_emails, params: {id: game.id}

    assert_redirected_to secret_santa_path

    delete :destroy, params: {id: game.id}

    assert_redirected_to secret_santa_path
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-102, FR-109)
  test 'allows administrator to create update and destroy game' do
    login_as(ADMIN_USER_ID)

    assert_difference('SecretSanta::Game.count', 1) do
      post :create, params: {
        secret_santa_game: {
          name: 'New Year Santa',
          message: 'Hello ((Giver_name))'
        }
      }
    end

    game = SecretSanta::Game.last

    assert_redirected_to secret_santa_game_path(game)

    patch :update, params: {
      id: game.id,
      secret_santa_game: {name: UPDATED_GAME_NAME}
    }

    assert_redirected_to secret_santa_game_path(game)
    assert_equal UPDATED_GAME_NAME, game.reload.name

    assert_difference('SecretSanta::Game.count', -1) do
      delete :destroy, params: {id: game.id}
    end
    assert_redirected_to secret_santa_path
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-103, FR-104, FR-105)
  test 'executes draw when at least 2 participants exist and sets error flash when fewer than 2 exist' do
    game = create_game
    create_player(user_id: ADMIN_USER_ID, want_to_get: 'HiddenWishText')
    login_as(ADMIN_USER_ID)

    post :draw, params: {id: game.id}

    assert_redirected_to secret_santa_game_path(game)
    assert flash[:error].present?
    assert_equal 0, game.assignments.count

    create_player(user_id: REGULAR_USER_ID)
    post :draw, params: {id: game.id}

    assert_redirected_to secret_santa_game_path(game)
    assert flash[:notice].present?
    assert_equal 2, game.assignments.count

    get :show, params: {id: game.id}

    assert_response :success
    assert_not_includes @response.body, 'HiddenWishText'
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-107, FR-108)
  test 'send_emails reports error without assignments and delivers emails after draw' do
    ActionMailer::Base.deliveries.clear
    game = create_game
    create_player(user_id: ADMIN_USER_ID)
    create_player(user_id: REGULAR_USER_ID)
    login_as(ADMIN_USER_ID)

    post :send_emails, params: {id: game.id}

    assert_redirected_to secret_santa_game_path(game)
    assert flash[:error].present?
    assert_equal 0, ActionMailer::Base.deliveries.size

    game.draw!
    post :send_emails, params: {id: game.id}

    assert_redirected_to secret_santa_game_path(game)
    assert flash[:notice].present?
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-101)
  test 'returns 404 when game does not exist' do
    login_as(ADMIN_USER_ID)

    get :show, params: {id: MISSING_GAME_ID}

    assert_response :not_found
  end
end
