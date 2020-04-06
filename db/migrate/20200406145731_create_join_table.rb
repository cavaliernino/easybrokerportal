class CreateJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :properties, :property_features do |t|
      # t.index [:property_id, :property_feature_id]
      # t.index [:property_feature_id, :property_id]
    end
  end
end
