# frozen_string_literal: true

require 'redmine'

Redmine::Plugin.register(:secret_santa) do
  name 'Periodic email reminder'
  author 'RK team'
  description 'Plugin to remind by email '
  version '1.0.1'
  url 'https://redmine-kanban.com/plugins/email_reporting'
  author_url 'https://redmine-kanban.com'

  project_module :secret_santa do
    permission :use_silent_mode, {silent: %i[on off]}, require: :loggedin
    permission :edit_reminders, {secret_santa: :all}, require: :loggedin
    permission :edit_any_reminders, {secret_santa: :all}, require: :loggedin
  end

  menu :account_menu,
       :silent_mode,
       {controller: :silent, action: :on},
       caption: :label_disable_notifications,
       after: :my_account, html: {'data-method' => 'put'},
       if: proc { User.current.allowed_to?(:use_silent_mode, nil, global: true) && User.current.pref[:silent].nil? }

  menu :application_menu,
       :secret_santa,
       {controller: :secret_santa, action: 'index'},
       caption: :label_secret_santa,
       last: true,
       if: proc { SecretSanta.allow_edit_my_or_any_reminders? }
end

require "#{File.dirname(__FILE__)}/lib/secret_santa"
