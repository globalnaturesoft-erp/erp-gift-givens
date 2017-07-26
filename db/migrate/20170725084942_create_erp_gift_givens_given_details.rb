class CreateErpGiftGivensGivenDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :erp_gift_givens_given_details do |t|
      t.integer :quantity, default: 1
      t.references :product, index: true, references: :erp_products_products
      t.references :given, index: true, references: :erp_gift_givens_givens

      t.timestamps
    end
  end
end
