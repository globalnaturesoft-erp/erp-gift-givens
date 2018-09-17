class AddConfirmedAtToErpGiftGivensGivens < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_gift_givens_givens, :confirmed_at, :datetime
  end
end
