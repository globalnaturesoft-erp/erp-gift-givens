module Erp::GiftGivens
  class Given < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :contact, class_name: "Erp::Contacts::Contact", foreign_key: :contact_id
    has_many :given_details, inverse_of: :given, dependent: :destroy
    accepts_nested_attributes_for :given_details, :reject_if => lambda { |a| a[:product_id].blank? || a[:warehouse_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }
    
    # Filters
    def self.filter(query, params)
      params = params.to_unsafe_hash
      
      # join with users table for search creator
      query = query.joins(:creator)
      
      # join with contacts table for search contact
      query = query.joins(:contact)
      
      and_conds = []
      
      #filters
      if params["filters"].present?
        params["filters"].each do |ft|
          or_conds = []
          ft[1].each do |cond|
            or_conds << "#{cond[1]["name"]} = '#{cond[1]["value"]}'"
          end
          and_conds << '('+or_conds.join(' OR ')+')' if !or_conds.empty?
        end
      end
      
      #keywords
      if params["keywords"].present?
        params["keywords"].each do |kw|
          or_conds = []
          kw[1].each do |cond|
            or_conds << "LOWER(#{cond[1]["name"]}) LIKE '%#{cond[1]["value"].downcase.strip}%'"
          end
          and_conds << '('+or_conds.join(' OR ')+')'
        end
      end
      
      # add conditions to query
      query = query.where(and_conds.join(' AND ')) if !and_conds.empty?
      
      # search by a given date
      if params[:date].present?
				date = params[:date].to_date
				query = query.where("given_date >= ? AND given_date <= ?", date.beginning_of_day, date.end_of_day)
			end
      
      return query
    end
    
    def self.search(params)
      query = self.order("created_at DESC")
      query = self.filter(query, params)
      
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
