module Erp
  module GiftGivens
    module Backend
      class GivensController < Erp::Backend::BackendController
        before_action :set_given, only: [:show_list, :pdf, :show, :xlsx, :edit, :update, :given_details,
                                          :set_draft, :set_activate, :set_delivery, :set_deleted]

        # GET /givens
        def index
          authorize! :sales_gift_givens_index, nil
        end

        # POST /givens/list
        def list
          authorize! :sales_gift_givens_index, nil
          
          @givens = Given.search(params).paginate(:page => params[:page], :per_page => 10)

          render layout: nil
        end

        # GET /given details
        def given_details
          render layout: nil
        end

        # GET /givens/1
        def show
          respond_to do |format|
            format.html
            format.pdf do
              render pdf: "show_list",
                layout: 'erp/backend/pdf'
            end
          end
        end

        # GET /orders/1
        def pdf
          authorize! :print, @given

          respond_to do |format|
            format.html
            format.pdf do
              if @given.given_details.count < 8
                render pdf: "#{@given.code}",
                  title: "#{@given.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A5',
                  orientation: 'Landscape',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              else
                render pdf: "#{@given.code}",
                  title: "#{@given.code}",
                  layout: 'erp/backend/pdf',
                  page_size: 'A4',
                  margin: {
                    top: 7,                     # default 10 (mm)
                    bottom: 7,
                    left: 7,
                    right: 7
                  }
              end
            end
          end
        end
        
        def xlsx
          authorize! :export_file, @given
          
          respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=\"Phieu xuat tang #{@given.code}.xlsx\""
            }
          end
        end

        # GET /givens/new
        def new
          @given = Given.new
          
          authorize! :create, @given
          
          @given.given_date = Time.current

          if request.xhr?
            render '_form', layout: nil, locals: {given: @given}
          end
        end

        # GET /givens/1/edit
        def edit
          authorize! :update, @given
        end

        # POST /givens
        def create
          @given = Given.new(given_params)
          
          authorize! :create, @given
          
          @given.creator = current_user
          @given.status = Erp::GiftGivens::Given::STATUS_ACTIVE

          if @given.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @given.code,
                value: @given.id
              }
            else
              redirect_to erp_gift_givens.backend_givens_path, notice: t('.success')
            end
          else
            if request.xhr?
              render '_form', layout: nil, locals: {given: @given}
            else
              render :new
            end
          end
        end

        # PATCH/PUT /givens/1
        def update
          authorize! :update, @given
          
          if @given.update(given_params)
            @given.set_activate
            if request.xhr?
              render json: {
                status: 'success',
                text: @given.code,
                value: @given.id
              }
            else
              redirect_to erp_gift_givens.backend_givens_path, notice: t('.success')
            end
          else
            render :edit
          end
        end

        # Activate /givens/status?id=1
        def set_activate
          authorize! :activate, @given
          
          @given.set_activate

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Delivery /givens/status?id=1
        def set_delivery
          authorize! :delivery, @given
          
          @given.set_delivery
          @given.update_confirmed_at

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        # Delete /givens/status?id=1
        def set_deleted
          authorize! :delete, @given
          
          @given.set_deleted

          respond_to do |format|
          format.json {
            render json: {
            'message': t('.success'),
            'type': 'success'
            }
          }
          end
        end

        private
          # Use callbacks to share common setup or constraints between actions.
          def set_given
            @given = Given.find(params[:id])
          end

          # Only allow a trusted parameter "white list" through.
          def given_params
            params.fetch(:given, {}).permit(:code, :given_date, :contact_id, :note,
                                            :given_details_attributes => [ :id, :product_id, :warehouse_id, :given_id, :quantity, :state_id, :_destroy ])
          end
      end
    end
  end
end
