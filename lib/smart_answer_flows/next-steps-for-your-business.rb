module SmartAnswer
  class NextStepsForYourBusinessFlow < Flow
    def define
      name "next-steps-for-your-business"
      content_id "4d7751b5-d860-4812-aa36-5b8c57253ff2"
      status :draft
      response_store :query_parameters

      # ======================================================================
      # What is your company registration number?
      # ======================================================================
      value_question :crn do
        on_response do |response|
          self.calculator = Calculators::NextStepsForYourBusinessCalculator.new
          calculator.crn = response
        end

        validate :error_company_not_found do
          calculator.company_exists?
        end

        next_node do
          question :annual_turnover
        end
      end

      # ======================================================================
      # Will your business take more than £85,000 in a 12 month period?
      # ======================================================================
      radio :annual_turnover do
        option :more_than_85k
        option :less_than_85k
        option :not_sure

        on_response do |response|
          turnover = response == "less_than_85k" ? 84_999 : 85_001
          calculator.business.estimated_annual_turnover = turnover
        end

        next_node do
          question :employ_someone
        end
      end

      # ======================================================================
      # Do you want to employ someone?
      # ======================================================================
      radio :employ_someone do
        option :yes
        option :already_employ
        option :no
        option :not_sure

        on_response do |response|
          calculator.business.employer = response != "no"
        end

        next_node do
          question :business_intent
        end
      end

      # ======================================================================
      # Does your business do any of the following?
      # ======================================================================
      checkbox_question :business_intent do
        option :buy_abroad
        option :sell_abroad
        option :sell_online
        none_option

        on_response do |response|
          intents = response.split(",")

          if intents.include?("buy_abroad")
            calculator.business.import_goods = true
          end

          if intents.include?("sell_abroad")
            calculator.business.export_goods = true
          end

          if intents.include?("sell_online")
            calculator.business.sell_goods_online = true
          end
        end

        next_node do
          question :business_support
        end
      end

      # ======================================================================
      # Are you looking for financial support for:
      # ======================================================================
      radio :business_support do
        option :yes
        option :no

        on_response do |response|
          calculator.business.needs_financial_support = response != "no"
        end

        next_node do
          question :business_premises
        end
      end

      # ======================================================================
      # Where are you running your business?
      # ======================================================================
      radio :business_premises do
        option :home
        option :renting
        option :elsewhere

        on_response do |response|
          calculator.business.has_non_domestic_property = response != "elsewhere"
        end

        next_node do
          outcome :results
        end
      end

      # ======================================================================
      # Outcome
      # ======================================================================
      outcome :results do
        view_template "smart_answers/custom_result"
      end
    end
  end
end
