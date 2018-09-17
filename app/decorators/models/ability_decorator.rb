Erp::Ability.class_eval do
  def gift_givens_ability(user)
    
    # xem va in pdf
    can :print, Erp::GiftGivens::Given do |given|
      given.is_delivered?
    end
    
    # xuat file excel
    can :export_file, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active? or given.is_delivered?
    end
    
    # kich hoat / xac nhan
    can :activate, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_deleted?
    end
    
    # giao hang
    can :delivery, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active?
    end
    
    # xoa / huy phieu
    can :delete, Erp::GiftGivens::Given do |given|
      (given.is_draft? or given.is_active? or given.is_delivered?) and
      user.get_permission(:sales, :gift_givens, :gift_givens, :delete) == 'yes'
    end
    
    # tao them phieu
    can :create, Erp::GiftGivens::Given do |given|
      user.get_permission(:sales, :gift_givens, :gift_givens, :create) == 'yes'
    end
    
    # cap nhat
    can :update, Erp::GiftGivens::Given do |given|
      (given.is_draft? or given.is_active? or given.is_delivered?) and
      user.get_permission(:sales, :gift_givens, :gift_givens, :update) == 'yes' or
      (
        user.get_permission(:sales, :gift_givens, :gift_givens, :update) == 'in_day' and
        (given.confirmed_at.nil? or Time.now < given.confirmed_at.end_of_day)
      )
    end
  end
end