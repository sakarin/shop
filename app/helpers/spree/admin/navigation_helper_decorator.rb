Spree::Admin::NavigationHelper.module_eval do

  def button(text, icon_name = nil, button_type = 'submit', options={})
    button_tag(content_tag('span', icon(icon_name) + ' ' + text), options.merge(:type => button_type, :id => "#{button_type}_#{text.downcase}"))
  end

  def button_link_to(text, url, html_options = {})
    if (html_options[:method] &&
        html_options[:method].to_s.downcase != 'get' &&
        !html_options[:remote])
      form_tag(url, :method => html_options.delete(:method)) do
        button(text, html_options.delete(:icon), nil, html_options)
      end
    else
      if html_options['data-update'].nil? && html_options[:remote]
        object_name, action = url.split('/')[-2..-1]
        html_options['data-update'] = [action, object_name.singularize].join('_')
      end
      html_options.delete('data-update') unless html_options['data-update']
      if html_options[:id].blank?
        link_to(text_for_button_link(text, html_options), url, html_options_for_button_link(html_options.merge(:id => text.downcase)))
      else
        link_to(text_for_button_link(text, html_options), url, html_options_for_button_link(html_options.merge(:id => html_options[:id].downcase)))
      end
    end
  end

  def tab(*args)
    options = {:label => args.first.to_s}
    if args.last.is_a?(Hash)
      options = options.merge(args.pop)
    end
    options[:route] ||= "admin_#{args.first}"

    destination_url = options[:url] || spree.send("#{options[:route]}_path")

    titleized_label = t(options[:label], :default => options[:label]).titleize

    link = link_to(titleized_label, destination_url)

    css_classes = []

    selected = if options[:match_path]
                 # TODO: `request.fullpath` for engines mounted at '/' returns '//'
                 # which seems an issue with Rails routing.- revisit issue #910
                 request.fullpath.gsub('//', '/').starts_with?("#{root_path}admin#{options[:match_path]}")

               else
                 args.include?(controller.controller_name.to_sym)
               end
    css_classes << 'selected' if selected

    if options[:css_class]
      css_classes << options[:css_class]
    end

    #content_tag('li', link, :class => css_classes.join(' '))
    unless options[:label] == 'product_customization_types' || options[:label] == 'promotions'
      content_tag('li', content_tag('span', icon(options[:label]) + ' ' + link), :class => css_classes.join(' '))
    end

  end

end
