module Erp::GiftGivens
  class GivenDetail < ApplicationRecord
    belongs_to :product, class_name: 'Erp::Products::Product', foreign_key: :product_id
    belongs_to :warehouse, class_name: 'Erp::Warehouses::Warehouse', foreign_key: :warehouse_id
    belongs_to :given, inverse_of: :given_details
    belongs_to :state, class_name: 'Erp::Products::State'
    
    validates :warehouse_id, :state_id, presence: true
    
    after_save :update_given_cache_products_count
    
    # update given cache products count
    def update_given_cache_products_count
			if given.present?
				given.update_cache_products_count
			end
		end
    
    def product_code
      product.nil? ? '' : product.code
    end
    
    def product_name
      product.nil? ? '' : product.name
    end
    
    def warehouse_name
      warehouse.nil? ? '' : warehouse.name
    end
    
    def state_name
      state.nil? ? '' : state.name
    end
  end
end
