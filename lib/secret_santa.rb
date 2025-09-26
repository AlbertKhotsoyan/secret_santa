# frozen_string_literal: true

module SecretSanta
  def self.allow_edit_santa?(user = User.current)
    user.admin? || user.allowed_to?(:edit_santa, nil, global: true)
  end
end
