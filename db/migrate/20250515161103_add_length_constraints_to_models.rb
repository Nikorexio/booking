class AddLengthConstraintsToModels < ActiveRecord::Migration[8.0]
  def change
    change_column :hotels, :name, :string, limit: 100
    change_column :hotels, :description, :text, limit: 1000
    
    change_column :cities, :name, :string, limit: 50
    
    change_column :rooms, :room_type, :string, limit: 30
    change_column :rooms, :number, :string, limit: 20
    
    change_column :reviews, :comment, :text, limit: 500
    
    change_column :users, :email, :string, limit: 150
  end
end
