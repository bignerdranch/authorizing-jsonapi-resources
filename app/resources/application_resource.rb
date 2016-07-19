class ApplicationResource < JSONAPI::Resource
  abstract

  private

  def self.current_user(options)
    options.fetch(:context).fetch(:current_user)
  end
end
