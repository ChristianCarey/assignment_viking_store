class RenameProductsDesriptionToDescription < ActiveRecord::Migration[5.0]
  def change
    rename_column :products, :desription, :description
  end
end
