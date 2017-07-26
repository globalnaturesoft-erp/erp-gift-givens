module Erp::GiftGivens
  class Given < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :contact, class_name: "Erp::Contacts::Contact", foreign_key: :contact_id
    has_many :given_details, inverse_of: :given, dependent: :destroy
    accepts_nested_attributes_for :given_details, :reject_if => lambda { |a| a[:product_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }
    
    def self.search(params)
      query = self.order("created_at DESC")
      query = self.all
      
      return query
    end
    
    def contact_name
      contact.present? ? contact.name : ''
    end
    
    def total_quantity
			return given_details.sum('quantity')
		end
  end
end
