# frozen_string_literal: true

require 'rack/session'
require 'logger'
require 'roda'
require 'figaro'
#require 'sequel'
require 'yaml'

module YouFind
  # Configuration for the App
  class App < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      use Rack::Session::Cookie, secret: config.SESSION_SECRET

      configure :development, :test do
        ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
        ENV['RAPID_API_TOKEN'] = config.API_KEY
      end

      # Database Setup
      #DB = Sequel.connect(ENV.fetch('DATABASE_URL', nil))
      #def self.DB = DB # rubocop:disable Naming/MethodName

      # Logger Setup
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock
  end
end
