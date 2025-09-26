# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register(:secret_santa) do
  name 'Secret Santa'
  author 'Albert Khotsoyan'
  description 'Play Secret Santa with Redmine group users'
  version '1.0.0'
  author_url 'albert.khotsoyan@gmail.com'

  project_module :secret_santa do
    permission :manage_secret_santa, {secret_santa: [:new, :create, :index, :show, :draw, :send_emails, :destroy]}, require: :loggedin
  end

  menu :application_menu,
       :secret_santa,
       {controller: :secret_santa, action: 'index'},
       caption: :label_secret_santa,
       last: true,
       if: proc { |_p| User.current.logged? }
end
