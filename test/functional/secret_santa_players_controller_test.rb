# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SecretSantaPlayersControllerTest < SecretSanta::ControllerTestCase
  UPDATED_GIFT_PREFERENCE = 'Noise-canceling headphones'
  MISSING_PLAYER_ID = 999_999

  # SPEC: docs/spec/01-player-registration.md (FR-001)
  test 'requires login for player actions' do
    get :new

    assert_response :redirect
  end

  # SPEC: docs/spec/01-player-registration.md (FR-002, FR-005)
  test 'creates participant for current authenticated user' do
    login_as(REGULAR_USER_ID)

    assert_difference('SecretSanta::Player.count', 1) do
      post :create, params: {
        secret_santa_player: {
          want_to_get: 'Coffee beans',
          dont_want_to_get: 'Perfume'
        }
      }
    end

    assert_redirected_to secret_santa_path
    player = SecretSanta::Player.find(REGULAR_USER_ID)

    assert_equal 'Coffee beans', player.want_to_get
    assert_equal 'Perfume', player.dont_want_to_get
  end

  # SPEC: docs/spec/01-player-registration.md (FR-006, FR-007)
  test 'allows owner to open edit form and redirects other users including administrators' do
    create_player(user_id: REGULAR_USER_ID, want_to_get: 'PrivateWish')

    login_as(REGULAR_USER_ID)
    get :edit, params: {id: REGULAR_USER_ID}

    assert_response :success
    assert_includes @response.body, 'PrivateWish'

    login_as(ADMIN_USER_ID)
    get :edit, params: {id: REGULAR_USER_ID}

    assert_redirected_to secret_santa_path
  end

  # SPEC: docs/spec/01-player-registration.md (FR-007)
  test 'allows owner or admin to update participant and returns 403 for other non-admin users' do
    create_player(user_id: REGULAR_USER_ID)

    login_as(SECOND_REGULAR_USER_ID)
    patch :update, params: {
      id: REGULAR_USER_ID,
      secret_santa_player: {want_to_get: UPDATED_GIFT_PREFERENCE}
    }

    assert_response :forbidden

    login_as(REGULAR_USER_ID)
    patch :update, params: {
      id: REGULAR_USER_ID,
      secret_santa_player: {want_to_get: UPDATED_GIFT_PREFERENCE}
    }

    assert_redirected_to secret_santa_path
    assert_equal UPDATED_GIFT_PREFERENCE, SecretSanta::Player.find(REGULAR_USER_ID).want_to_get
  end

  # SPEC: docs/spec/01-player-registration.md (FR-007, FR-008)
  test 'blocks participant deletion when participating in assignments and allows deletion when unassigned' do
    create_player(user_id: ADMIN_USER_ID)
    create_player(user_id: REGULAR_USER_ID)
    game = create_game
    game.draw!

    login_as(SECOND_REGULAR_USER_ID)
    delete :destroy, params: {id: REGULAR_USER_ID}

    assert_response :forbidden

    login_as(REGULAR_USER_ID)
    assert_no_difference('SecretSanta::Player.count') do
      delete :destroy, params: {id: REGULAR_USER_ID}
    end
    assert_redirected_to secret_santa_path
    assert flash[:error].present?

    game.destroy!
    assert_difference('SecretSanta::Player.count', -1) do
      delete :destroy, params: {id: REGULAR_USER_ID}
    end
    assert_redirected_to secret_santa_path
  end

  # SPEC: docs/spec/01-player-registration.md (FR-007)
  test 'returns 404 when participant does not exist' do
    login_as(ADMIN_USER_ID)

    get :edit, params: {id: MISSING_PLAYER_ID}

    assert_response :not_found
  end

  # SPEC: docs/spec/01-player-registration.md (FR-002, FR-004)
  test 'redirects already registered participant away from new and create actions' do
    create_player(user_id: REGULAR_USER_ID)
    login_as(REGULAR_USER_ID)

    get :new

    assert_redirected_to secret_santa_path

    assert_no_difference('SecretSanta::Player.count') do
      post :create, params: {
        secret_santa_player: {
          want_to_get: 'Duplicate registration attempt'
        }
      }
    end

    assert_redirected_to secret_santa_path
  end
end
