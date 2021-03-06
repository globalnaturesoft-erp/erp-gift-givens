module Erp::GiftGivens
  class Given < ApplicationRecord
    belongs_to :creator, class_name: "Erp::User"
    belongs_to :contact, class_name: "Erp::Contacts::Contact", foreign_key: :contact_id
    has_many :given_details, inverse_of: :given, dependent: :destroy
    accepts_nested_attributes_for :given_details, :reject_if => lambda { |a| a[:product_id].blank? || a[:warehouse_id].blank? || a[:quantity].blank? || a[:quantity].to_i <= 0 }, :allow_destroy => true

    after_save :update_cache_products_count

    validates :code, uniqueness: true
    validates :given_date, :contact_id, presence: true

    # class const
    STATUS_DRAFT = 'draft'
    STATUS_ACTIVE = 'active'
    STATUS_DELIVERED = 'delivered'
    STATUS_DELETED = 'deleted'
    
    # update confirmed at
    def update_confirmed_at
      self.update_columns(confirmed_at: Time.now)
    end

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
      # if params[:date].present?
			# 	date = params[:date].to_date
			# 	query = query.where("given_date >= ? AND given_date <= ?", date.beginning_of_day, date.end_of_day)
			# end

			# global filters
      global_filter = params[:global_filter]

			if global_filter.present?

        # if has period
        if global_filter[:period].present?
          period = Erp::Periods::Period.find(global_filter[:period])
          global_filter[:from_date] = period.from_date
          global_filter[:to_date] = period.to_date
        end

				# filter by order from date
				if global_filter[:from_date].present?
					query = query.where('given_date >= ?', global_filter[:from_date].to_date.beginning_of_day)
				end

				# filter by order to date
				if global_filter[:to_date].present?
					query = query.where('given_date <= ?', global_filter[:to_date].to_date.end_of_day)
				end

				# filter by given from date
				if global_filter[:given_from_date].present?
					query = query.where('given_date >= ?', global_filter[:given_from_date].to_date.beginning_of_day)
				end

				# filter by given to date
				if global_filter[:given_to_date].present?
					query = query.where('given_date <= ?', global_filter[:given_to_date].to_date.end_of_day)
				end

				# filter by contact
				if global_filter[:contact].present?
					query = query.where(contact_id: global_filter[:contact])
				end
			end
			
			# single keyword
      if params[:keyword].present?
				keyword = params[:keyword].strip.downcase
				keyword.split(' ').each do |q|
					q = q.strip
					query = query.where('LOWER(erp_gift_givens_givens.cache_search) LIKE ?', '%'+q+'%')
				end
			end

      return query
    end

    def self.search(params)
      query = self.all
      query = self.filter(query, params)

      # order
      if params[:sort_by].present?
        order = params[:sort_by]
        order += " #{params[:sort_direction]}" if params[:sort_direction].present?

        query = query.order(order)
      else
				query = query.order('created_at desc')
      end

      return query
    end

    # display creator name
    def creator_name
      creator.present? ? creator.name : ''
    end

    # Set status for stock transfer
    def set_draft
      update_attributes(status: Erp::GiftGivens::Given::STATUS_DRAFT)
    end

    def set_activate
      update_attributes(status: Erp::GiftGivens::Given::STATUS_ACTIVE)
    end

    def set_delivery
      update_attributes(status: Erp::GiftGivens::Given::STATUS_DELIVERED)
    end

    def set_deleted
      update_attributes(status: Erp::GiftGivens::Given::STATUS_DELETED)
    end

    # check if gift given is draft/active/delivered/deleted
    def is_draft?
      return self.status == Erp::GiftGivens::Given::STATUS_DRAFT
    end

    def is_active?
      return self.status == Erp::GiftGivens::Given::STATUS_ACTIVE
    end

    def is_delivered?
      return self.status == Erp::GiftGivens::Given::STATUS_DELIVERED
    end

    def is_deleted?
      return self.status == Erp::GiftGivens::Given::STATUS_DELETED
    end

    # display contact name
    def contact_name
      contact.present? ? contact.name : ''
    end

    # Total item count for transfer details
    def total_quantity
			return given_details.sum('quantity')
		end

    # Update cache products count
    def update_cache_products_count
			self.update_column(:cache_products_count, self.total_quantity)
		end

    # Generate code
    before_validation :generate_code
    def generate_code
			if !code.present?
				num = Erp::GiftGivens::Given.where('given_date >= ? AND given_date <= ?', self.given_date.beginning_of_month, self.given_date.end_of_month).count + 1

				self.code = 'XT' + given_date.strftime("%m") + given_date.strftime("%Y").last(2) + "-" + num.to_s.rjust(3, '0')
			end
		end
    
    # Update casche search
    after_save :update_cache_search
		def update_cache_search
			str = []
			str << code.to_s.downcase.strip
			str << contact_name.to_s.downcase.strip
			str << creator_name.to_s.downcase.strip
			given_details.each do |gd|
        str << gd.product_name.to_s.downcase.strip
        str << gd.warehouse_name.to_s.downcase.strip
			end

			self.update_column(:cache_search, str.join(" ") + " " + str.join(" ").to_ascii)
		end
    
    # check stock available
    def check_stock_available
      self.given_details.each do |given_detail|
        if given_detail.quantity > given_detail.product.get_stock(warehouse_ids: given_detail.warehouse_id, state_ids: given_detail.state_id)
          return false
        end
      end
      return true
    end
    
    def check_stock_status
      if status == Erp::GiftGivens::Given::STATUS_ACTIVE
        if check_stock_available == false
          'out_of_stock'
        else
          'in_stock'
        end
      end
    end
  end
end
