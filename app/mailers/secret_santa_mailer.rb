# frozen_string_literal: true

class SecretSantaMailer < Mailer
  GIVER_NAME_PLACEHOLDER = '((Giver_name))'
  RECEIVER_NAME_PLACEHOLDER = '((Receiver_name))'
  PREFERRED_GIFTS_PLACEHOLDER = '((Receiver_preferred_gifts))'
  AVOID_GIFTS_PLACEHOLDER = '((Receiver_avoid_these_gifts))'
  EMPTY_GIFT_FALLBACK = '-'

  def santa_email(giver, assignment)
    @giver = giver
    @receiver = assignment.receiver
    @game = assignment.game
    @subject = parse_template_vars(assignment.game.name, @giver, @receiver)
    @message = parse_template_vars(@game.message, @giver, @receiver)

    mail(to: giver.mail, subject: @subject) do |format|
      format.html {render('secret_santa/mailer/santa_email')}
    end
  end

private

  def parse_template_vars(template_text, giver, receiver)
    return template_text if template_text.blank? || !template_text.respond_to?(:gsub)

    template_text
      .gsub(GIVER_NAME_PLACEHOLDER, giver.name.to_s)
      .gsub(RECEIVER_NAME_PLACEHOLDER, receiver.user.name.to_s)
      .gsub(PREFERRED_GIFTS_PLACEHOLDER, receiver.want_to_get.presence || EMPTY_GIFT_FALLBACK)
      .gsub(AVOID_GIFTS_PLACEHOLDER, receiver.dont_want_to_get.presence || EMPTY_GIFT_FALLBACK)
  end
end
