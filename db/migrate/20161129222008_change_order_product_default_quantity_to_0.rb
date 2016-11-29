class ChangeOrderProductDefaultQuantityTo0 < ActiveRecord::Migration[5.0]
  def change
    change_column :order_products, :quantity, :integer, default: 0
  end
end
