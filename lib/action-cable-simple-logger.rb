if defined?(ActionCable)
  require "action-cable-simple-logger/log_subscriber"

  require "action-cable-simple-logger/action_cable/channel/base"
  require "action-cable-simple-logger/action_cable/connection/base"
  require "action-cable-simple-logger/action_cable/server/base"
end

module ActionCableSimpleLogger
  class Configuration
    attr_accessor :enabled, :logger, :log_level
  end

  def setup
    if defined?(ActionCable)
      self.config ||= ActionCableSimpleLogger::Configuration.new

      yield self.config

      return unless self.config.enabled

      ActionCableSimpleLogger::LogSubscriber.attach_to :action_cable
    end
  end
end
