class CreateHotels < ActiveRecord::Migration[8.0]
  def change
    create_table :hotels do |t|
      t.string :name
      t.text :description
      t.string :address
      t.references :city, null: false, foreign_key: true
      t.float :rating

      t.timestamps
    end
  end
end
