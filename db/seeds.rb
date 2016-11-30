# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

MULTIPLIER  = 1
USER_NUM    = MULTIPLIER * 100
ADDRESS_NUM = USER_NUM * 4
CITY_NUM    = MULTIPLIER * 100
PRODUCTS_PER_CATEGORY_NUM = 20
CATEGORIES  = ['Axes', 'Helmets', 'Meat', 'Armor', 'Life-vests'].map do |name|
  Category.create(name: name)
end


def address_params
  {
    street1:           Faker::Address.street_address,
    street2:           Faker::Address.secondary_address,
    zip:               Faker::Address.zip_code,
    state_or_province: Faker::Address.state
  }
end
  
def product_params
  {
    name:        Faker::Commerce.product_name,
    description: Faker::Lorem.sentence(2),
    price:       Faker::Commerce.price,
    sku:         Faker::Code.ean
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

def address_without_user
  Address.where('user_id IS NULL').limit(1).first
end

def add_address(user, address, args = {})
  address.user_id = user.id
  args.each do |k,v|
    address.send("#{k}=", v)
  end
  address.save!
end

def add_addresses(user)
  billing_address = address_without_user
  add_address(user, billing_address, kind: "billing", default: true)
  shipping_address = address_without_user
  add_address(user, shipping_address, kind: "shipping", default: true)
  rand(3).times do 
    address = address_without_user
    add_address(user, address)
  end
  [billing_address, shipping_address]
end



def add_shipment(order, shipping_address)
  order.update_attribute(:placed_time, Time.now)  
  Shipment.create!(order_id: order.id, shipped_on: Time.now, 
                   tracking_number: Faker::Number.number(10),
                   shipping_address_id: shipping_address.id)
end


def random_product
  Product.all.sample
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

def time_between(date1, date2)
  Time.at((date2.to_f - date1.to_f)*rand + date1.to_f)
end

city_list = []

CITY_NUM.times do
  city_list << Faker::Address.city
end

ADDRESS_NUM.times do
  address = Address.new(address_params)
  address.city_id = City.find_or_create_by(name: city_list.sample).id
  address.save
end

CATEGORIES.length.times do |n|
  PRODUCTS_PER_CATEGORY_NUM.times do 
    product = Product.new(product_params)
    product.category_id = CATEGORIES[n].id
    product.save
  end
end

USER_NUM.times do |n|
  user = User.create!(user_params)
  billing_address, shipping_address = add_addresses(user)
  order = add_order(user, billing_address, n)
  if n < USER_NUM / 4 
    order.update_attribute(:placed_time, time_between(1.year.ago, 6.months.ago))
  elsif n >= USER_NUM / 4  && n < (USER_NUM / 4) * 2
    order.update_attribute(:placed_time, time_between(6.months.ago, 1.months.ago))
  else
    order.update_attribute(:placed_time, time_between(1.months.ago, Time.now))
  end
  add_shipment(order, shipping_address) if n.even?
end
