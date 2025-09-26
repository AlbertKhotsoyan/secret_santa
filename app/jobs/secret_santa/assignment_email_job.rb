# frozen_string_literal: true

class SecretSanta::AssignmentEmailJob < ActiveJob::Base
  queue_as :default

  # Arguments: game_id (Integer), assignment_id (Integer)
  def perform(game_id, assignment_id)
    game = SecretSanta::Game.find_by(id: game_id)
    assignment = SecretSanta::Assignment.find_by(id: assignment_id)
    return unless game && assignment

    giver = assignment.giver
    receiver = assignment.receiver
    return if giver.nil? || receiver.nil? || giver.mail.blank?

    # deliver email synchronously inside the job (mail transport is handled by your environment)
    SecretSanta::Mailer.with(game: game, assignment: assignment).assignment_email.deliver_now
  rescue StandardError => e
    Rails.logger.error("SecretSanta::AssignmentEmailJob failed for assignment #{assignment_id}: #{e.message}")
    raise e
  end
end
