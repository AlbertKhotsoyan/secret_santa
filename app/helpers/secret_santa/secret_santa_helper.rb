# frozen_string_literal: true

module SecretSanta
  module SecretSantaHelper
    def player_actions(player)
      links = []
      links << link_to(l(:button_edit), edit_secret_santa_player_path(player.id)) if User.current.id == player.id
      links << link_to(l(:button_delete), secret_santa_player_path(player.id), data: {confirm: l(:text_are_you_sure)}, method: :delete) if User.current.id == player.id || User.current.admin?

      safe_join(links, ' | ')
    end

    def game_actions(game)
      links = []
      links << link_to(l(:button_show), secret_santa_game_path(game))
      links << link_to(l(:button_edit), edit_secret_santa_game_path(game))
      links << link_to(l(:button_delete), secret_santa_game_path(game), method: :delete, data: {confirm: l(:text_are_you_sure)})

      safe_join(links, ' | ')
    end

    def email_presence(player)
      if player.mail.present?
        l(:label_email_information, address: player.mail)
      else
        l(:hint_add_an_email_to_account)
      end
    end

    def santa_letter_text_area(game, mailing_options = {})
      letter_text = game.message
      text_area_tag('secret_santa_game[message]', letter_text, mailing_options).html_safe
    end
  end
end
