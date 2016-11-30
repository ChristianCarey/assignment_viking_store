class OrderProduct < ApplicationRecord

  def self.add(product, order)
    order_product = where(product_id: product.id, order_id: order.id).first_or_initialize
    order_product.quantity += 1
    order_product.order_id = order.id
    order_product.save
  end
end
