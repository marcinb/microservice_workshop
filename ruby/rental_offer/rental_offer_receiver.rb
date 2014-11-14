#!/usr/bin/env ruby
# encoding: utf-8

require_relative 'connection'
require_relative 'rental_offer_need_packet'
require_relative 'rental_offer_solution_packet'

class RentalOfferReceiver
  def initialize(host, bus_name)
    @host = host
    @bus_name = bus_name
  end

  def start
    Connection.with_open(@host, @bus_name) {|ch, ex| receive(ch, ex) }
  end

private
  def need(packet_body)
    RentalOfferNeedPacket.from_json(packet_body)
  end

  def receive(channel, exchange)
    queue = channel.queue("", :exclusive => true)
    queue.bind exchange

    queue.subscribe(block: true) do |delivery_info, properties, body|
      need = need(body)

      puts "[x] Hey, I have this rental offer for you, #{need}" if  need.has_solutions?
    end
  end

end

RentalOfferReceiver.new(ARGV.shift, ARGV.shift).start
