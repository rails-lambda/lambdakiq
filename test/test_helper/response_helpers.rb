module TestHelper
  module ResponseHelpers
    extend ActiveSupport::Concern

    private

    def assert_response(response, failures: false, identifiers: [])
      expect(response).must_be_instance_of Hash
      expect(response[:batchItemFailures]).must_be_instance_of Array
      if failures
        assert_response_failures response, identifiers: identifiers
      else
        expect(response[:batchItemFailures]).must_be :empty?
      end
    end

    def assert_response_failures(response, identifiers: [])
      expect(response[:batchItemFailures]).wont_be :empty?
      return if identifiers.blank?
      expect(response[:batchItemFailures].length).must_equal identifiers.length
      response[:batchItemFailures].each_with_index do |failure, index|
        expect(failure[:itemIdentifier]).must_equal identifiers[index]
      end
    end

  end
end
