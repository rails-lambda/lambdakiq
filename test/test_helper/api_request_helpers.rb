module TestHelper
  module ApiRequestHelpers

    private

    def delete_message
      api_requests.reverse.detect do |r|
        r[:operation_name] == :delete_message
      end
    end

    def change_message_visibility
      api_requests.reverse.detect do |r|
        r[:operation_name] == :change_message_visibility
      end
    end

    def change_message_visibility_params
      change_message_visibility[:params]
    end

    def sent_message
      api_requests.reverse.detect do |r|
        r[:operation_name] == :send_message
      end
    end

    def sent_message_params
      sent_message[:params]
    end

    def sent_message_body
      JSON.parse sent_message_params[:message_body]
    end

    def sent_message_attributes
      sent_message_params[:message_attributes]
    end

  end
end
