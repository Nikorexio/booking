class AddCanceledAtToReservations < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :canceled_at, :datetime
  end
end
