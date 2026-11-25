# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register(:secret_santa) do
  name 'Secret Santa'
  version '1.0.3'
  author 'Albert Khotsoyan'
  description 'A Redmine plugin that allows users to participate in a Secret Santa game directly inside Redmine.'
  author_url 'albert.khotsoyan@gmail.com'
  requires_redmine version_or_higher: '6.0'

  menu :top_menu,
       :secret_santa,
       {controller: :secret_santa, action: 'index'},
       caption: :label_secret_santa,
       last: true
end

require_relative 'lib/secret_santa'
