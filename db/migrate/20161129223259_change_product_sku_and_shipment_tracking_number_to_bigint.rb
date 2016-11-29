class ChangeProductSkuAndShipmentTrackingNumberToBigint < ActiveRecord::Migration[5.0]
  def change
    change_column :products, :sku, :bigint
    change_column :shipments, :tracking_number, :bigint
  end
end
