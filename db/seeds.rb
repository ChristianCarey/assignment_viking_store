# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def address_params
  {
    city:              Faker::Address.city,
    street1:           Faker::Address.street_address,
    street2:           Faker::Address.secondary_address,
    zip:               Faker::Address.zip_code,
    state_or_province: Faker::Address.state
  }
end

def product_params
  categories = ["Axes", "Helmets", "Meat"]
  {
    name:        Faker::Commerce.product_name,
    description: Faker::Lorem.sentence(2),
    price:       Faker::Commerce.price,
    sku:         Faker::Code.ean,
    category_id: Category.find_or_create_by(name: categories.sample).id
  }
end

def user_params
  name = Faker::Name.name
  {
    name:         name,
    email:        Faker::Internet.email(name), 
    phone_number: Faker::PhoneNumber.phone_number
  }
end


def add_addresses(user)
  billing_address = Address.new(address_params)
  billing_address.default = true
  billing_address.type = "billing"
  billing_address.user_id = user.id
  billing_address.save!
  shipping_address = Address.new(address_params)
  shipping_address.default = true
  shipping_address.type = "shipping"
  shipping_address.user_id = user.id
  shipping_address.save!
  [billing_address, shipping_address]
end



def add_shipment(order, shipping_address)
  order.update_attribute(:placed_time, Time.now)  
  Shipment.create!(order_id: order.id, shipped_on: Time.now, 
                   tracking_number: Faker::Number.number(10),
                   shipping_address_id: shipping_address.id)
end


def random_product
  Product.create!(product_params)
end


def add_order(user, billing_address, n)
  order = Order.create(user_id: user.id, billed_to_id: billing_address.id)
  3.times { OrderProduct.add(random_product, order) }
  if n % 3 == 0
    product = random_product
    2.times { OrderProduct.add(product, order)}
  end
  order
end

100.times do 

end

101.times do |n|
  user = User.create!(user_params)
  billing_address, shipping_address = add_addresses(user)
  order = add_order(user, billing_address, n)
  add_shipment(order, shipping_address) if n.even?
end
