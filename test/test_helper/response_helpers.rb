module TestHelper
  module ResponseHelpers
    extend ActiveSupport::Concern

    private

    def assert_response(response, failures: false, identifiers: [])
      expect(response).must_be_instance_of Hash
      expect(response[:BatchItemFailures]).must_be_instance_of Array
      if failures
        assert_response_failures response, identifiers: identifiers
      else
        expect(response[:BatchItemFailures]).must_be :empty?
      end
    end

    def assert_response_failures(response, identifiers: [])
      expect(response[:BatchItemFailures]).wont_be :empty?
      return if identifiers.blank?
      expect(response[:BatchItemFailures].length).must_equal identifiers.length
      response[:BatchItemFailures].each_with_index do |failure, index|
        expect(failure[:ItemIdentifier]).must_equal identifiers[index]
      end
    end

  end
end
