class Currency < ApplicationRecord
  validates :code, presence: true, uniqueness: true
end
