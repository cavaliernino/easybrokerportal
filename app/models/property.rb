class Property < ApplicationRecord
  has_many :properties_property_features, dependent: :destroy
  has_many :property_features, through: :properties_property_features

  belongs_to :property_type
  belongs_to :currency
  belongs_to :user

  validates :property_type, :title, :description, :currency, presence: true
  validate :operation_present?

  def operation_present?
    unless sale? || rental?
      errors.add :base, 'Must specify at least one operation'
    end
  end
end
