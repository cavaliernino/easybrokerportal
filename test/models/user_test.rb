require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'create' do
    user = User.new email: 'homer@simpson.com',
      first_name: 'Homer',
      last_name: 'Simpson',
      company: 'Simpsons Co'
    assert user.save
  end

  test 'required fields' do
    user = User.new
    refute user.valid?
    assert user.errors.has_key? :email
    assert user.errors.has_key? :first_name
    assert user.errors.has_key? :last_name
    refute user.errors.has_key? :company
  end

  test 'relations' do
    assert_equal 1, users(:bart).properties.count
  end
end
