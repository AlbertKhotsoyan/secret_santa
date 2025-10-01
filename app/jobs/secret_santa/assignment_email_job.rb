# frozen_string_literal: true

class SecretSanta::AssignmentEmailJob < ActiveJob::Base
  queue_as :default

  def perform(game_id, assignment_id)
    game = SecretSanta::Game.find_by(id: game_id)
    assignment = SecretSanta::Assignment.find_by(id: assignment_id)
    return unless game && assignment

    giver = assignment.giver
    receiver = assignment.receiver

    # Guards: do not attempt to send if giver/receiver missing or giver has no email
    if giver.nil?
      Rails.logger.warn("SecretSanta::AssignmentEmailJob: giver is nil for assignment #{assignment_id}, skipping")
      return
    end

    if receiver.nil?
      Rails.logger.warn("SecretSanta::AssignmentEmailJob: receiver is nil for assignment #{assignment_id}, skipping")
      return
    end

    if giver.mail.blank?
      Rails.logger.warn("SecretSanta::AssignmentEmailJob: giver #{giver.id} has no email, skipping assignment #{assignment_id}")
      return
    end

    # Call Redmine-style mailer method that expects User as first argument
    ::SecretSanta::Mailer.assignment_email(giver, game, assignment).deliver_now
  rescue StandardError => e
    Rails.logger.error("SecretSanta::AssignmentEmailJob failed for assignment #{assignment_id}: #{e.class}: #{e.message}\n#{e.backtrace.take(10).join("\n")}")
    raise e
  end
end
