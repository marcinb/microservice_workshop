require 'json'

# Understands solutions to a need for a rental car offer
class RentalOfferNeedPacket
  NEED = 'car_rental_offer'

  def self.from_json(json)
    solutions = JSON.load(json).fetch('solutions', [])
    new(solutions)
  end

  def initialize(solutions = [], member_user = false)
    @solutions = solutions
    @member_user = member_user
  end

  def to_json(*args)
    {
      'json_class' => self.class.name,
      'need' => NEED,
      'member_user' => @member_user,
      'solutions' => @solutions
    }.to_json
  end

  alias_method :to_s, :to_json

  def has_solutions?
    !@solutions.empty?
  end

  def propose_solution(solution)
    @solutions << solution
  end

  def for_member?
    !!@member_user
  end

end

