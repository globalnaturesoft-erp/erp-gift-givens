class AddCacheSearchToErpGiftGivensGivens < ActiveRecord::Migration[5.1]
  def change
    add_column :erp_gift_givens_givens, :cache_search, :text
  end
end
