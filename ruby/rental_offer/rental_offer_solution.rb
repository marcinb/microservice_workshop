#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connection'
require_relative 'rental_offer_need_packet'

# Streams rental-offer-related requests to the console
class RentalOfferSolution

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
    RentalOfferSolutionPacket.new(1000, "Trabant")
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

      if need.has_solutions?
        puts " [x] Solution already found. Ignoring..."
      else
        solution = propose_solution_for(need, exchange)
        puts " [x] Proposed solutions: #{solution}"
      end
    end
  end

end

RentalOfferSolution.new(ARGV.shift, ARGV.shift).start
