# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SecretSantaGameTest < SecretSanta::UnitTestCase
  # SPEC: docs/spec/02-game-management-and-draw.md (FR-102)
  test 'validates presence of game name' do
    game = SecretSanta::Game.new(name: '', message: 'Hello')

    assert_not game.valid?
    assert game.errors[:name].present?
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-103)
  test 'draw! raises NotEnoughPlayersError when fewer than 2 participants exist' do
    game = create_game

    assert_raises(SecretSanta::Game::NotEnoughPlayersError) do
      game.draw!
    end

    create_player(user_id: REGULAR_USER_ID)

    assert_raises(SecretSanta::Game::NotEnoughPlayersError) do
      game.draw!
    end
    assert_equal 0, game.assignments.count
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-104)
  test 'draw! creates single-cycle derangement and replaces previous assignments on re-run' do
    player_ids = [ADMIN_USER_ID, REGULAR_USER_ID, SECOND_REGULAR_USER_ID]
    player_ids.each { |uid| create_player(user_id: uid) }
    game = create_game

    game.draw!
    assignments = game.assignments.reload

    assert_equal player_ids.size, assignments.size
    assert_equal player_ids.sort, assignments.map(&:giver_id).sort
    assert_equal player_ids.sort, assignments.map(&:receiver_id).sort
    assignments.each do |assignment|
      assert_not_equal assignment.giver_id, assignment.receiver_id
    end

    game.draw!

    assert_equal player_ids.size, game.assignments.reload.size
  end

  # SPEC: docs/spec/01-player-registration.md (FR-008)
  # SPEC: docs/spec/02-game-management-and-draw.md (FR-109)
  test 'count_for_player tracks giver assignments and game destruction cascades to assignments' do
    create_player(user_id: ADMIN_USER_ID)
    create_player(user_id: REGULAR_USER_ID)
    game = create_game
    game.draw!

    assert_equal 1, SecretSanta::Assignment.count_for_player(REGULAR_USER_ID)

    game.destroy!

    assert_equal 0, SecretSanta::Assignment.count_for_player(REGULAR_USER_ID)
  end

  # SPEC: docs/spec/02-game-management-and-draw.md (FR-106, FR-107)
  test 'send_santa_emails delivers personalized html emails with fallback and without mutating game attributes' do
    ActionMailer::Base.deliveries.clear
    create_player(user_id: ADMIN_USER_ID, want_to_get: 'Mechanical keyboard', dont_want_to_get: '')
    create_player(user_id: REGULAR_USER_ID, want_to_get: '', dont_want_to_get: 'Candy')
    original_name = 'Secret Santa for ((Giver_name))'
    original_message = 'Hello ((Giver_name)), buy for ((Receiver_name)). Wants: ((Receiver_preferred_gifts)). Avoid: ((Receiver_avoid_these_gifts)).'
    game = create_game(name: original_name, message: original_message)
    game.draw!

    game.send_santa_emails

    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_equal original_name, game.name
    assert_equal original_message, game.message

    admin_user = User.find(ADMIN_USER_ID)
    regular_user = User.find(REGULAR_USER_ID)
    admin_mail = ActionMailer::Base.deliveries.find { |mail| mail.to.include?(admin_user.mail) }

    assert_not_nil admin_mail
    assert_includes admin_mail.subject, admin_user.name
    assert_includes admin_mail.body.encoded, regular_user.name
    assert_includes admin_mail.body.encoded, 'Candy'
    assert_includes admin_mail.body.encoded, '-'
  end
end
