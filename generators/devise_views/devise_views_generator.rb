class DeviseViewsGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      views_directory = File.join('app', 'views')
      m.directory views_directory

      {
        :sessions => [:new],
        :passwords => [:new, :edit],
        :confirmations => [:new],
        :notifier => [:confirmation_instructions, :reset_password_instructions]
      }.each do |dir, templates|
        m.directory File.join(views_directory, dir.to_s)

        templates.each do |template|
          template_path = "#{dir}/#{template}.html.erb"
          m.file "#{template_path}", "#{views_directory}/#{template_path}"
        end
      end
    end
  end

end
