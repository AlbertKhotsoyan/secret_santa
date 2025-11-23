# frozen_string_literal: true

class SecretSantaMailer < Mailer
  def santa_email(giver, assignment)
    @giver = giver # Class User
    @receiver = assignment.receiver
    @game = assignment.game
    @subject = assignment.game.name
    @message = parse_template_vars(@game.message, @giver, @receiver)

    mail(to: giver.mail, subject: @subject) do |format|
      format.html {render('secret_santa/mailer/santa_email')}
    end
  end

private

  def parse_template_vars(str, giver, receiver)
    if str.respond_to?(:gsub!) && str.present?
      str.gsub!('((Giver_name))', giver.name)
      str.gsub!('((Receiver_name))', receiver.user.name)
      str.gsub!('((Receiver_preferred_gifts))', receiver.want_to_get.presence || '---------')
      str.gsub!('((Receiver_avoid_these_gifts))', receiver.dont_want_to_get.presence || '---------')
    end
    str
  end
end
