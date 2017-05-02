module DeviseHelper
  # set { full_messages: false } if you need messages by skipping started attribute name, default value true
  # set { head: false } if you need to avoid head part of error messages, default value true
  #
  # A simple way to show error messages for the current devise resource. If you need
  # to customize this method, you can either overwrite it in your application helpers or
  # copy the views to your application.
  #
  # This method is intended to stay simple and it is unlikely that we are going to change
  # it to add more behavior or options.
  def devise_error_messages!(*options)
    return '' if resource.errors.empty?

    params = options[0].present? ? options[0] : {}

    if params.has_key?(:full_messages) && params[:full_messages] == false
      messages = resource.errors.messages.map {|att, messages| messages.map { |msg| content_tag(:li, msg) }.join }.join
    else
      messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    end

    sentence = I18n.t('errors.messages.not_saved',
                      count: resource.errors.count,
                      resource: resource.class.model_name.human.downcase)

    if params.has_key?(:head) && params[:head] == false
      html = <<-HTML
      <div id="error_explanation">
        <ul>#{messages}</ul>
      </div>
      HTML
    else
      html = <<-HTML
      <div id="error_explanation">
        <h2>#{sentence}</h2>
        <ul>#{messages}</ul>
      </div>
      HTML
    end

    html.html_safe
  end
end
