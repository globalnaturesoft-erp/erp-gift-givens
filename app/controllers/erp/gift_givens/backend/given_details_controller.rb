module Erp
  module GiftGivens
    module Backend
      class GivenDetailsController < Erp::Backend::BackendController
        def given_line_form
          @given_detail = GivenDetail.new
          @given_detail.product_id = params[:add_value]
          @given_detail.state = Erp::Products::State.first

          render partial: params[:partial], locals: {
            given_detail: @given_detail,
            uid: helpers.unique_id()
          }
        end
      end
    end
  end
end
