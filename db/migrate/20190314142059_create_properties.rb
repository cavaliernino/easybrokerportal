class CreateProperties < ActiveRecord::Migration[5.2]
  def change
    create_table :properties do |t|
      t.boolean :published, null: false, default: false
      t.string :title, null: false
      t.string :description, null: false
      t.boolean :rental, null: false, default: false
      t.decimal :rent
      t.boolean :sale, null: false, default: false
      t.decimal :sale_price
      t.integer :bedrooms
      t.integer :bathrooms
      t.integer :parking_spaces
      t.references :property_type, null: false
      t.references :currency, null: false
      t.references :user, null: false
      t.timestamps
    end
  end
end
