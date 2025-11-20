# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register(:secret_santa) do
  name 'Secret Santa'
  author 'Albert Khotsoyan'
  description 'Play Secret Santa in Redmine'
  version '1.0.2'
  author_url 'albert.khotsoyan@gmail.com'

  menu :application_menu,
       :secret_santa,
       {controller: :secret_santa, action: 'index'},
       caption: :label_secret_santa,
       last: true
end
