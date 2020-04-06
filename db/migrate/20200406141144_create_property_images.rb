class CreatePropertyImages < ActiveRecord::Migration[5.2]
  def change
    create_table :property_images do |t|
      t.integer :order
      t.string :url
      t.references :property, foreign_key: true

      t.timestamps
    end
  end
end
