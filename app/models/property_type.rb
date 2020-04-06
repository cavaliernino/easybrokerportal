class PropertyType < ApplicationRecord
  validates :name, presence: true, uniqueness: true
end
