module TestHelper
  module MessageHelpers

    private

    def sent_message
      client.api_requests.reverse.detect { |r|
        r[:operation_name] == :send_message
      } || flunk('No sent message request found.')
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
