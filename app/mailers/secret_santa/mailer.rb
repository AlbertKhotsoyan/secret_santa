# frozen_string_literal: true

# Use Redmine's Mailer so we get its settings and templates
class SecretSanta::Mailer < Mailer
  # NOTE: Redmine's Mailer expects the first argument to be a User object.
  # So signature must be: assignment_email(giver_user, game, assignment)
  def assignment_email(giver, game, assignment)
    return if giver.nil? || !giver.is_a?(User)

    @game = game
    @assignment = assignment
    @giver = giver
    @receiver = assignment.receiver

    subject_template =
      (Setting.plugin_secret_santa && Setting.plugin_secret_santa['default_subject'].presence) ||
      I18n.t('secret_santa.mailer.assignment_subject', game: @game.name)

    # Support "%{game}" interpolation if present
    subject = begin
                sprintf(subject_template, game: @game.name)
              rescue StandardError
                subject_template
              end

    body_template = @game.message_template.presence ||
                    (Setting.plugin_secret_santa && Setting.plugin_secret_santa['default_message'].presence) ||
                    I18n.t('secret_santa.mailer.assignment_body_default')

    body = body_template.gsub('{{giver_name}}', @giver.name.to_s)
                        .gsub('{{receiver_name}}', @receiver&.name.to_s)
                        .gsub('{{receiver_email}}', @receiver&.mail.to_s)
                        .gsub('{{game_name}}', @game.name.to_s)

    # Use Redmine's Mailer mail(...) call; first argument is not required here because
    # we already passed the giver as the first method parameter.
    mail(to: @giver.mail, subject: subject) do |format|
      format.text { render(plain: body) }
      format.html { render(html: "<pre>#{ERB::Util.html_escape(body)}</pre>".html_safe) }
    end
  end
end
