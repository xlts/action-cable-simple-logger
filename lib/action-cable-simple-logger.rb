module ActionCableSimpleLogger
  class Configuration
    attr_accessor :enabled, :logger, :log_level, :format
  end

  class << self
    attr_accessor :config

    def setup
      self.config ||= ActionCableSimpleLogger::Configuration.new

      self.config.log_level = :info

      yield self.config

      return unless self.config.enabled
      return unless defined?(ActionCable)

      require "action-cable-simple-logger/rails_extensions/action_cable/channel/base"
      require "action-cable-simple-logger/rails_extensions/action_cable/connection/base"
      require "action-cable-simple-logger/rails_extensions/action_cable/server/base"
      require "action-cable-simple-logger/log_subscriber"

      ActionCableSimpleLogger::LogSubscriber.attach_to :action_cable
    end
  end
end
