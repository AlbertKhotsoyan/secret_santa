# frozen_string_literal: true

class SecretSanta::Mailer < ApplicationMailer
  default from: Setting.mail_from

  def assignment_email
    @game = params[:game]
    @assignment = params[:assignment]
    @giver = @assignment.giver
    @receiver = @assignment.receiver

    # Determine subject: per-game subject not implemented so use plugin setting + game name interpolation
    subject_template =
      Setting.plugin_secret_santa && Setting.plugin_secret_santa['default_subject'].presence ||
      I18n.t('mailer.assignment_subject', game: @game.name) ||
      I18n.t('secret_santa.mailer.assignment_subject', game: @game.name)

    # If plugin subject contains %{game}, interpolate
    subject = begin
                sprintf(subject_template, game: @game.name)
              rescue StandardError
                subject_template
              end

    body_template = @game.message_template.presence ||
                    (Setting.plugin_secret_santa && Setting.plugin_secret_santa['default_message'].presence) ||
                    I18n.t('secret_santa.mailer.assignment_body_default')

    body = body_template.gsub('{{giver_name}}', @giver.name.to_s)
                        .gsub('{{receiver_name}}', @receiver.name.to_s)
                        .gsub('{{receiver_email}}', @receiver.mail.to_s)
                        .gsub('{{game_name}}', @game.name.to_s)

    mail(to: @giver.mail, subject: subject) do |format|
      format.text { render(plain: body) }
      format.html { render(html: "<pre>#{ERB::Util.html_escape(body)}</pre>".html_safe) }
    end
  end
end
