class ApplicationResource < JSONAPI::Resource
  include Pundit

  abstract

  private

  def current_user
    context.fetch(:current_user)
  end

  def self.current_user(options)
    options.fetch(:context).fetch(:current_user)
  end
end
