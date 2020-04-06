require 'test_helper'

class PropertyTest < ActiveSupport::TestCase
  test 'create' do
    property = Property.new
    property.title = 'Cool House'
    property.description = 'Super description of cool house'
    property.property_type = property_types(:house)
    property.sale = true
    property.currency = currencies(:usd)
    property.user = users(:bart)
    assert property.save
  end

  test 'operation_present?' do
    house = properties(:simpson_house)
    house.sale = false
    house.rental = false

    refute house.valid?
    house.sale = true
    assert house.valid?

    house.sale = false
    house.rental = true
    assert house.valid?
  end
end
