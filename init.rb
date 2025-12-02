# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register(:secret_santa) do
  name 'Secret Santa'
  author 'Albert Khotsoyan'
  description 'A Redmine plugin that allows users to participate in a Secret Santa game directly inside Redmine.'
  version '1.0.0'
  author_url 'albert.khotsoyan@gmail.com'

  menu :top_menu,
       :secret_santa,
       {controller: :secret_santa, action: 'index'},
       caption: :label_secret_santa,
       last: true
end
