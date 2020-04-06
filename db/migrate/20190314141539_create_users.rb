class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :company
      t.string :phone
      t.string :first_name
      t.string :last_name
      t.timestamps
    end
  end
end
