class RenameAddressCityToCityId < ActiveRecord::Migration[5.0]
  def change
    rename_column :addresses, :city, :city_id
  end
end
