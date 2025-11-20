# frozen_string_literal: true

class SecretSantaMailer < Mailer
  def santa_email(giver, assignment)
    @giver = giver
    @receiver = assignment.receiver
    @game = assignment.game
    @subject = assignment.game.name

    mail(to: giver.mail, subject: @subject) do |format|
      format.html {render('secret_santa/mailer/santa_email')}
    end
  end
end
