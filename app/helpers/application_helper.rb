# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
   def display_flash_messages
    html = ''
    flash.each do |css_class, message|
      html << content_tag(:p, content_tag(:span,  content_tag(:img)) + message  ,:class => css_class, :onclick => "closeFlashes();")
    end
    html
  end
end
