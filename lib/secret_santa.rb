# frozen_string_literal: true

module SecretSanta
  def self.allow_edit_reminders?(user = User.current)
    user.allowed_to?(:edit_reminders, nil, global: true)
  end

  def self.allow_edit_any_reminders?(user = User.current)
    user.admin? || user.allowed_to?(:edit_any_reminders, nil, global: true)
  end

  def self.allow_edit_my_or_any_reminders?(user = User.current)
    allow_edit_reminders?(user) || allow_edit_any_reminders?(user)
  end
end
