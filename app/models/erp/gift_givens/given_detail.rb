module Erp::GiftGivens
  class GivenDetail < ApplicationRecord
    belongs_to :product, class_name: 'Erp::Products::Product', foreign_key: :product_id
    belongs_to :warehouse, class_name: 'Erp::Warehouses::Warehouse', foreign_key: :warehouse_id
    belongs_to :given, inverse_of: :given_details
    
    def product_code
      product.nil? ? '' : product.code
    end
    
    def product_name
      product.nil? ? '' : product.name
    end
    
    def warehouse_name
      warehouse.nil? ? '' : warehouse.name
    end
  end
end
