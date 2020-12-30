module TestHelper
  module Jobs
    module Buffer
      class << self
        def clear
          values.clear
        end

        def add(value)
          values << value
        end

        def values
          @values ||= []
        end

        def last_value
          values.last
        end
      end
    end
  end
end
