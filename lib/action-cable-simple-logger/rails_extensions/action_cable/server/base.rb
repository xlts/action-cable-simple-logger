module ActionCable
  module Server
    class Base
      mattr_accessor :logger
      self.logger = Logger.new(nil)
    end
  end
end
