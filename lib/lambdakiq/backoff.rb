module Lambdakiq
  class Backoff

    MAX_VISIBILITY_TIMEOUT = 43200 # 12 Hours

    attr_reader :count

    class << self

      def backoff(count)
        new(count).backoff
      end

    end

    def initialize(count)
      @count = count
    end

    # From Sidekiq: https://git.io/fhi5O
    #
    def backoff
      case count
      when 1 then 30
      when 2 then 46
      when 3 then 76
      when 4 then 156
      when 5 then 346
      when 6 then 730
      when 7 then 1416
      when 8 then 2536
      when 9 then 4246
      when 10 then 6726
      when 11 then 10180
      when 12 then 14836
      end
    end

  end
end
