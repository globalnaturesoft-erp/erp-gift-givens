user = Erp::User.first
contacts = Erp::Contacts::Contact.where('id != ?', Erp::Contacts::Contact.get_main_contact.id)
status = [Erp::GiftGivens::Given::STATUS_DRAFT,
          Erp::GiftGivens::Given::STATUS_ACTIVE,
          Erp::GiftGivens::Given::STATUS_DELIVERED,
          Erp::GiftGivens::Given::STATUS_DELETED]


Erp::GiftGivens::Given.all.destroy_all
(1..20).each do |num|
  contact = contacts.order("RANDOM()").first
  given = Erp::GiftGivens::Given.create(
    code: 'GG'+ num.to_s.rjust(3, '0'),
    given_date: Time.now,
    contact_id: contact.id,
    status: status[rand(status.count)],
    creator_id: user.id
  )
  Erp::Products::Product.where(id: Erp::Products::Product.pluck(:id).sample(rand(1..5))).each do |product|
    Erp::GiftGivens::GivenDetail.create(
      product_id: product.id,
      given_id: given.id,
      quantity: rand(1..3),
      warehouse_id: Erp::Warehouses::Warehouse.order("RANDOM()").first.id,
      state_id: Erp::Products::State.first.id
    )
  end
end