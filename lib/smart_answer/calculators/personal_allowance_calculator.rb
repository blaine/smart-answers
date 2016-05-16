module SmartAnswer::Calculators
  class PersonalAllowanceCalculator
    # created for married couples allowance calculator.
    # this could be extended for use across smart answers
    # and/or GOV.UK

    # if you earn over the income limit for age-related allowance
    # then your age-related allowance is reduced by £1 for every £2
    # you earn over the limit until the personal allowance is reached,
    # at which point reduction stops (the basic personal allowance is not
    # reduced)

    # in addition, if you earn over the income limit for personal allowance
    # your personal allwowance is reduced in the same way. In the year 2012-13
    # this limit was £100,000 so no need to include it in this calculation
    # as we've already gone way over where it would make a difference to your MCA.

    # so this class could be extended so that it returns the personal allowance
    # you are entitled to based on your age and income.

    def age_on_fifth_april(birth_date)
      fifth_april = Date.new(Date.today.year, 4, 5)
      fifth_april.year - birth_date.year
    end

    def age_related_allowance(birth_date)
      age = age_on_fifth_april(birth_date)
      if age < 65
        age_related_allowance = personal_allowance
      elsif age < 75
        age_related_allowance = over_65_allowance
      else
        age_related_allowance = over_75_allowance
      end
    end

    def personal_allowance
      rates.personal_allowance
    end

    def income_limit_for_personal_allowances
      rates.income_limit_for_personal_allowances
    end

  private

    def over_65_allowance
      rates.over_65_allowance
    end

    def over_75_allowance
      rates.over_75_allowance
    end

    def rates
      @rates ||= RatesQuery.from_file('personal_allowance').rates
    end
  end
end
