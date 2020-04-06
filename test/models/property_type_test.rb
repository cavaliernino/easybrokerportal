require 'test_helper'

class PropertyTypeTest < ActiveSupport::TestCase
  test 'create' do
    assert PropertyType.create! name: 'Test'
    refute PropertyType.new(name: 'Test').valid?
  end

  test 'requires name' do
    property_type = PropertyType.new
    refute property_type.valid?

    property_type.name = 'Test'
    assert property_type.valid?
  end
end
