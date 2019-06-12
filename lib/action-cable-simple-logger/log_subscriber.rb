module ActionCableSimpleLogger
  class LogSubscriber < ActiveSupport::LogSubscriber
    %i(perform_action subscribe unsubscribe connect disconnect).each do |method_name|
      define_method(method_name) do |event|
        process_event(event)
      end
    end

    def logger
      @logger ||= ActionCableSimpleLogger.config.logger.presence || super
    end

    private

    def process_event(event)
      message_hash = build_message_hash(event)
      logger.public_send(ActionCableSimpleLogger.config.log_level, formatted_message(message_hash))
    end

    def build_message_hash(event)
      payload = event.payload

      {
        params: payload[:data],
        controller: payload[:channel_class] || payload[:connection_class],
        action: payload[:action],
        duration: event.duration.to_f.round(2),
      }.merge(calculate_status(event.payload))
    end

    def calculate_status(payload)
      error = payload[:exception]

      if error
        exception, message = error
        { status: get_error_status_code(exception), error: "#{exception}: #{message}" }
      else
        { status: default_status }
      end
    end

    def get_error_status_code(exception)
      status = ActionDispatch::ExceptionWrapper.rescue_responses[exception]
      Rack::Utils.status_code(status)
    end

    def default_status
      200
    end

    def formatted_message(message_hash)
      custom_format = ActionCableSimpleLogger.config.format
      if custom_format
        custom_format.call(message_hash)
      else
        default_formatted_message(message_hash)
      end
    end

    def default_formatted_message(message_hash)
      "[Action Cable] [#{message_hash[:status]}] (#{message_hash[:controller]}##{message_hash[:action]})"
    end
  end
end
