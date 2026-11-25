# frozen_string_literal: true

module SecretSanta
  module SecretSantaHelper
    ACTION_SEPARATOR = ' | '

    def player_actions(player)
      own_player = User.current.id == player.id
      links = []
      links << link_to(l(:button_edit), edit_secret_santa_player_path(player.id)) if own_player
      links << link_to(l(:button_delete), secret_santa_player_path(player.id), data: {confirm: l(:text_are_you_sure)}, method: :delete) if own_player || User.current.admin?

      safe_join(links, ACTION_SEPARATOR)
    end

    def game_actions(game)
      links = [
        link_to(l(:button_show), secret_santa_game_path(game)),
        link_to(l(:button_edit), edit_secret_santa_game_path(game)),
        link_to(l(:button_delete), secret_santa_game_path(game), method: :delete, data: {confirm: l(:text_are_you_sure)}),
      ]

      safe_join(links, ACTION_SEPARATOR)
    end

    def email_presence(player)
      if player.mail.present?
        l(:label_email_information, address: player.mail)
      else
        l(:hint_add_an_email_to_account)
      end
    end

    def santa_letter_text_area(game, mailing_options = {})
      text_area_tag('secret_santa_game[message]', game.message, mailing_options)
    end
  end
end
