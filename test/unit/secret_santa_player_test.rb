# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SecretSantaPlayerTest < SecretSanta::UnitTestCase
  CHAR = 'a'

  # SPEC: docs/spec/01-player-registration.md (FR-002)
  test 'creates participant linked to redmine user and enforces uniqueness per user' do
    player = create_player(user_id: REGULAR_USER_ID)

    assert player.persisted?
    assert_equal User.find(REGULAR_USER_ID), player.user

    duplicate_player = SecretSanta::Player.new(id: REGULAR_USER_ID, want_to_get: 'Tea')

    assert_not duplicate_player.valid?
    assert duplicate_player.errors[:id].present?
  end

  # SPEC: docs/spec/01-player-registration.md (FR-002)
  test 'requires user identifier to be present' do
    player = SecretSanta::Player.new(id: nil, want_to_get: 'Mug')

    assert_not player.valid?
    assert player.errors[:id].present?
  end

  # SPEC: docs/spec/01-player-registration.md (FR-005)
  test 'enforces maximum length of 2000 characters on gift preferences' do
    max_text = CHAR * SecretSanta::Player::MAX_PREFERENCE_LENGTH
    too_long_text = CHAR * (SecretSanta::Player::MAX_PREFERENCE_LENGTH + 1)

    valid_player = SecretSanta::Player.new(
      id: REGULAR_USER_ID,
      want_to_get: max_text,
      dont_want_to_get: max_text
    )

    assert valid_player.valid?

    invalid_want_player = SecretSanta::Player.new(
      id: REGULAR_USER_ID,
      want_to_get: too_long_text
    )

    assert_not invalid_want_player.valid?
    assert invalid_want_player.errors[:want_to_get].present?

    invalid_avoid_player = SecretSanta::Player.new(
      id: SECOND_REGULAR_USER_ID,
      dont_want_to_get: too_long_text
    )

    assert_not invalid_avoid_player.valid?
    assert invalid_avoid_player.errors[:dont_want_to_get].present?
  end
end
