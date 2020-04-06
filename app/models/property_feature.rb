class PropertyFeature < ApplicationRecord
    has_many :properties_property_features
    has_many :properties, through: :properties_property_feature
end
