#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_packet'
require_relative 'connection'

# Expresses a need for rental car offers
class RentalOfferNeed

  def initialize(host, bus_name)
    @host = host
    @bus_name = bus_name
  end

  def start
    Connection.with_open(@host, @bus_name) {|ch, ex| publish_need(ch, ex)}
  end

  private

  def publish_need(channel, exchange)
    exchange.publish RentalOfferNeedPacket.new.to_json
    puts " [x] Published a rental offer need on the #{@bus_name} bus"
  end

end

RentalOfferNeed.new(ARGV.shift, ARGV.shift).start
