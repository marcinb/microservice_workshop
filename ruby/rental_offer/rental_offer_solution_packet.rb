class RentalOfferSolutionPacket
  def initialize(price, car_brand)
    @price = price
    @car_brand = car_brand
  end

  def to_json(*args)
    {
      'json_class' => self.class.name,
      'price' => @price,
      'car_brand' => @car_brand
    }.to_json
  end
end

