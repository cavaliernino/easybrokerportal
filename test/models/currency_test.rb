require 'test_helper'

class CurrencyTest < ActiveSupport::TestCase
  test 'create' do
    currency = Currency.create code: 'EUR'
    assert currency.save
    currency.code = 'USD'
    refute currency.save
  end

  test 'required fields' do
    currency = Currency.new
    refute currency.valid?
    currency.code = 'EUR'
    assert currency.valid?
  end
end
