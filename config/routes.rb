Erp::GiftGivens::Engine.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    namespace :backend, module: "backend", path: "backend/gift_givens" do
      resources :givens do
        collection do
          post 'list'
          get 'given_details'
          put 'set_activate'
          put 'set_delivery'
          put 'set_delete'
          post 'show_list'
          get 'pdf'
        end
      end
      resources :given_details do
        collection do
          get 'given_line_form'
        end
      end
    end
  end
end