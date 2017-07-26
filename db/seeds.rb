puts "---------- Gift Givens Engine ------------"
user = Erp::User.first
contact = Erp::Contacts::Contact.first
product = Erp::Products::Product.first

puts "Create sample gift given"
Erp::GiftGivens::Given.where(code: "GG001").destroy_all
given = Erp::GiftGivens::Given.create(
  code: "GG001",
  given_date: Time.now,
  contact_id: contact.id,
  creator_id: user.id
)
puts given.errors.to_json if !given.errors.empty?

puts "Create sample gift given detail"
given_detail = Erp::GiftGivens::GivenDetail.create(
  product_id: product.id,
  given_id: given.id,
  quantity: 2
)
puts given_detail.errors.to_json if !given_detail.errors.empty?