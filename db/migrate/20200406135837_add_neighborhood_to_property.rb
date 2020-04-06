class AddNeighborhoodToProperty < ActiveRecord::Migration[5.2]
  def change
    add_column :properties, :neighborhood, :string
  end
end
