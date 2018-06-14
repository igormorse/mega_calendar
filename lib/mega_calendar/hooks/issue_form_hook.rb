module MegaCalendar
  module Hooks
    class IssueFormHook < Redmine::Hook::ViewListener
      render_on :view_issues_form_details_top, partial: 'mega_calendar_hooks/time_fields_requires'
      render_on :view_issues_attributes_after_start_date, partial: 'mega_calendar_hooks/insert_time_begin_field'
      render_on :view_issues_attributes_after_due_date, partial: 'mega_calendar_hooks/insert_time_end_field'
      render_on :view_issues_attributes_before_custom_fields, partial: 'mega_calendar_hooks/time_fields_js_action'
      render_on :view_issues_attributes_details_bottom, partial: 'mega_calendar_hooks/time_fields_js_edit_action'


      def view_layouts_base_html_head(context = {})
        return stylesheet_link_tag('jquery-clockpicker.min.css', plugin: 'mega_calendar')
      end
    end
  end
end
