module ActionCableSimpleLogger
  class LogSubscriber
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
      # TODO format message

      message_hash = message(event)
      logger.send(ActionCableSimpleLogger.config.log_level, formatted_message(message_hash))
    end

    def message(event)
      payload = event.payload

      {
        params: payload[:data],
        controller: payload[:channel_class] || payload[:connection_class],
        action: payload[:action],
        duration: event.duration.to_f.round(2),
        status: calculate_status(event.payload)
      }
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

    def extract_runtimes(event, _payload)
      { duration: event.duration.to_f.round(2) }
    end
  end
end