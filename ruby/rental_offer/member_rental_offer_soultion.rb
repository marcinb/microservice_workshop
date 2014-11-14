#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connection'
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_packet'

# Streams rental-offer-related requests to the console
class MemberRentalOfferSolution

  def initialize(host, bus_name)
    @host = host
    @bus_name = bus_name
  end

  def start
    Connection.with_open(@host, @bus_name) {|ch, ex| monitor_solutions(ch, ex) }
  end

private
  def need(packet_body)
    RentalOfferNeedPacket.from_json(packet_body)
  end

  def solution_for(need)
    RentalOfferSolutionPacket.new(1000000, "Awesme car. AWESOME.")
  end

  def propose_solution_for(need, exchange)
    need.tap do |need|
      need.propose_solution(solution_for(need))
      exchange.publish need.to_json
    end
  end

  def monitor_solutions(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange

    queue.subscribe(block: true) do |delivery_info, properties, body|
      need = need(body)
      puts " [x] Received need: #{need}"

      if need.for_member?
        return puts " [x] Solution already found. Ignoring..." if need.has_solutions? &&
        solution = propose_solution_for(need, exchange)
        puts " [x] Proposed solutions: #{solution}"
      end
    end
  end

end

MemberRentalOfferSolution.new(ARGV.shift, ARGV.shift).start
