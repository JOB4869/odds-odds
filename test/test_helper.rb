ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "devise"

Rails.application.routes.default_url_options[:host] = "example.com"

module ActiveSupport
  class TestCase
    include Devise::Test::IntegrationHelpers
    include Rails.application.routes.url_helpers
    parallelize(workers: :number_of_processors)

    fixtures :all

    # Set default url options for mailers
    parallelize_setup do |worker|
      ActionMailer::Base.default_url_options[:host] = "example.com"
    end

    parallelize_teardown do |worker|
      # Cleanup if necessary
    end

    # Helper method for signing in users in integration tests
    def integration_sign_in(user)
      post new_session_path, params: { user: { email: user.email, password: "password" } }
    end

    def default_url_options
      { host: "example.com" }
    end
  end
end

class ActionDispatch::IntegrationTest
  include Rails.application.routes.url_helpers

  def setup
    super
    @default_url_options = { host: "example.com" }
  end
end
