module Erp
  module GiftGivens
    module Backend
      class GivensController < Erp::Backend::BackendController
        before_action :set_given, only: [:show, :edit, :update, :destroy, :given_details,
                                          :set_draft, :set_activate, :set_delivery, :set_delete]
    
        # GET /givens
        def index
        end
        
        # POST /givens/list
        def list
          @givens = Given.search(params).paginate(:page => params[:page], :per_page => 10)
          
          render layout: nil
        end
        
        # GET /given details
        def given_details
          render layout: nil
        end
    
        # GET /givens/1
        def show
        end
    
        # GET /givens/new
        def new
          @given = Given.new
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
          @given.creator = current_user
          @given.set_draft
    
          if @given.save
            if request.xhr?
              render json: {
                status: 'success',
                text: @given.code,
                value: @given.id
              }
            else
              redirect_to erp_gift_givens.edit_backend_given_path(@given), notice: t('.success')
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
          if @given.update(given_params)
            @given.set_draft
            if request.xhr?
              render json: {
                status: 'success',
                text: @given.code,
                value: @given.id
              }
            else
              redirect_to erp_gift_givens.edit_backend_given_path(@given), notice: t('.success')
            end
          else
            render :edit
          end
        end
    
        # DELETE /givens/1
        def destroy
          @given.destroy
          
          respond_to do |format|
            format.html { redirect_to erp_gift_givens.backend_givens_path, notice: t('.success') }
            format.json {
              render json: {
                'message': t('.success'),
                'type': 'success'
              }
            }
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
        def set_delete
          authorize! :delete, @given
          @given.set_delete

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
                                            :given_details_attributes => [ :id, :product_id, :warehouse_id, :given_id, :quantity, :_destroy ])
          end
      end
    end
  end
end
