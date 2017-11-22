Erp::Ability.class_eval do
  def gift_givens_ability(user)
    
    can :activate, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_deleted?
    end
    
    can :delivery, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active?
    end
    
    can :delete, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active? or given.is_delivered?
    end
    
    can :update, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active? or given.is_delivered?
    end
    
    can :print, Erp::GiftGivens::Given do |given|
      given.is_active? or given.is_delivered?
    end
    
    can :export_file, Erp::GiftGivens::Given do |given|
      given.is_draft? or given.is_active? or given.is_delivered?
    end
  end
end