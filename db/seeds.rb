user = Erp::User.first
contacts = ['Marcus Doe', 'Nick Larson', 'Richard Stone', 'Paul Kiton', 'Mark	Otto']

# Contacts
contacts.each do |c|
  Erp::Contacts::Contact.where(name: c).destroy_all
  num = Erp::Contacts::Contact.all.order('id DESC').first.id
  Erp::Contacts::Contact.create(
    contact_type: Erp::Contacts::Contact::TYPE_PERSON,
    name: c,
    code: 'CUS'+ num.to_s.rjust(3, '0'),
    creator_id: user.id
  )
end


Erp::GiftGivens::Given.all.destroy_all
(1..20).each do |num|
  contact_ps = Erp::Contacts::Contact.where(contact_type: Erp::Contacts::Contact::TYPE_PERSON).order("RANDOM()").first
  given = Erp::GiftGivens::Given.create(
    code: 'GG'+ num.to_s.rjust(3, '0'),
    given_date: Time.now,
    contact_id: contact_ps.id,
    creator_id: user.id
  )
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(1..5))).each do |product|
    Erp::GiftGivens::GivenDetail.create(
      product_id: product.id,
      given_id: given.id,
      quantity: rand(1..3)
    )
  end
end