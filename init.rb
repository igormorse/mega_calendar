require 'filters.rb'
require 'vpim'

# Redmine::Plugin.requires_plugin('redmine_plugin_name')

Redmine::Plugin.register :mega_calendar do
  name 'Mega Calendar plugin'
  author 'Andreas Treubert && Visagio'
  description 'Better calendar for redmine'
  version '2.0.0'
  url 'https://github.com/igormorse/mega_calendar'
  author_url 'https://github.com/berti92'
  requires_redmine :version_or_higher => '3.0.1'

  # When migrating for first time it will not find the Users Table so this checking prevents this
  # from happening.
  if User.table_exists?
    menu(:top_menu, :calendar, { :controller => 'calendar', :action => 'index' }, :caption => :calendar, :if => Proc.new {(Setting.try(:plugin_mega_calendar)[:calendar_active] == "true" && ((!Setting.try(:plugin_mega_calendar)[:allowed_users].blank? && Setting.try(:plugin_mega_calendar)[:allowed_users].include?(User.current.id.to_s)) || (!Setting.try(:plugin_mega_calendar)[:allowed_groups].blank? && User.current.groups.collect{|group| Setting.try(:plugin_mega_calendar)[:allowed_groups].include?(group.id.to_s)}.include?(true))) rescue false)})
    # menu(:top_menu, :holidays, { :controller => 'holidays', :action => 'index' }, :caption => :holidays, :if => Proc.new {(!Setting.plugin_mega_calendar['allowed_users'].blank? && Setting.plugin_mega_calendar['allowed_users'].include?(User.current.id.to_s) ? true : false)})
    settings :default => {
      'display_empty_dates' => 0, 
      'displayed_type' => 'users', 
      'displayed_users' => User.table_exists? ? User.where(["users.login IS NOT NULL AND users.login <> ''"]).collect {|x| x.id.to_s} : [], 
      'default_holiday_color' => 'D59235', 
      'default_event_color' => '4F90FF', 
      'sub_path' => '/', 
      'week_start' => '1', 
      'allowed_users' => User.table_exists? ? User.where(["users.login IS NOT NULL AND users.login <> ''"]).collect {|x| x.id.to_s} : []},
      'calendar_default_buttons' => ['allTickets', 'myTickets', 'refresh'],
      :partial => 'settings/mega_calendar_settings'
  end

  Issue.send(:include, MegaCalendar::Patches::IssuePatch) unless Issue.included_modules.include? MegaCalendar::Patches::IssuePatch
  IssuesController.send(:include, MegaCalendar::Patches::IssuesControllerPatch) unless IssuesController.included_modules.include? MegaCalendar::Patches::IssuesControllerPatch
  UsersController.send(:include, MegaCalendar::Patches::UsersControllerPatch) unless UsersController.included_modules.include? MegaCalendar::Patches::UsersControllerPatch
end
