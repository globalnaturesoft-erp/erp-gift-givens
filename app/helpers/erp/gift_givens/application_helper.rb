module Erp
  module GiftGivens
    module ApplicationHelper
      
      # Gift given dropdown actions
      def gift_given_dropdown_actions(given)
        actions = []
        actions << {
          text: '<i class="fa fa-print"></i> '+t('.view_print'),
          href: erp_gift_givens.backend_given_path(given)
        } if can? :print, given
        actions << {
          text: '<i class="fa fa-edit"></i> '+t('.edit'),
          url: erp_gift_givens.edit_backend_given_path(given),
        } if can? :update, given
        actions << {
          text: '<i class="fa fa-check-square-o"></i> '+t('.activate'),
          url: erp_gift_givens.set_activate_backend_givens_path(id: given),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.activate_confirm')
        } if can? :activate, given
        actions << {
          text: '<i class="fa fa-send-o"></i> '+t('.delivery'),
          url: erp_gift_givens.set_delivery_backend_givens_path(id: given),
          data_method: 'PUT',
          class: 'ajax-link',
          data_confirm: t('.delivery_confirm')
        } if can? :delivery, given
        actions << { divider: true } if can? :delete, given
        actions << {
          text: '<i class="fa fa-trash"></i> '+t('.delete'),
          url: erp_gift_givens.set_delete_backend_givens_path(id: given),
          data_method: 'PUT',
          hide: given.is_deleted?,
          class: 'ajax-link',
          data_confirm: t('.delete_confirm')
        } if can? :delete, given
        
        erp_datalist_row_actions(
          actions
        )
        
      end
      
    end
  end
end
