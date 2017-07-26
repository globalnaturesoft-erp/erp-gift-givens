class CreateErpGiftGivensGivens < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_gift_givens_givens do |t|
      t.string :code
      t.datetime :given_date
      t.references :creator, index: true, references: :erp_users
      t.references :contact, index: true, references: :erp_contacts_contacts
      t.text :note

      t.timestamps
    end
  end
end
