require "date"

module SmartAnswer
  module Question
    class Date < Base
      def validate_in_range
        @validate_in_range = true
      end

      def from(&block)
        if block_given?
          @from_func = block
        else
          @from_func && @from_func.call
        end
      end

      def to(&block)
        if block_given?
          @to_func = block
        else
          @to_func && @to_func.call
        end
      end

      def default_day(&block)
        if block_given?
          @default_day_func = block
        else
          @default_day_func && @default_day_func.call
        end
      end

      def default_month(&block)
        if block_given?
          @default_month_func = block
        else
          @default_month_func && @default_month_func.call
        end
      end

      def default_year(&block)
        if block_given?
          @default_year_func = block
        else
          @default_year_func && @default_year_func.call
        end
      end

      def range
        @range ||= from && to ? from..to : false
      end

      def parse_input(input)
        date = case input
               when Hash, ActiveSupport::HashWithIndifferentAccess
                 input = input.symbolize_keys
                 year_month_and_day = [
                   default_year || input[:year],
                   default_month || input[:month],
                   default_day || input[:day],
                 ]
                 raise InvalidResponse unless year_month_and_day.all?(&:present?)

                 ::Date.new(*year_month_and_day.map(&:to_i))
               when String
                 ::Date.parse(input)
               when ::Date
                 input
               else
                 raise InvalidResponse, "Bad date", caller
               end

        validate_input(date) if @validate_in_range
        date
      rescue ArgumentError => e
        if e.message =~ /invalid date/
          raise InvalidResponse, "Bad date: #{input.inspect}", caller
        else
          raise
        end
      end

      def to_response(input)
        date = parse_input(input)
        {
          day: date.day,
          month: date.month,
          year: date.year,
        }
      rescue InvalidResponse
        nil
      end

      def date_of_birth_defaults
        from { 122.years.ago.beginning_of_year.to_date }
        to { ::Time.zone.today.end_of_year }
        validate_in_range
      end

    private

      def validate_input(date)
        return unless range

        min, max = [range.begin, range.end].sort
        if date < min || date > max
          raise InvalidResponse, "Provided date is out of range: #{date}", caller
        end
      end
    end
  end
end
