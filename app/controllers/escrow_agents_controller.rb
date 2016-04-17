class EscrowAgentsController < ApplicationController
	before_action :set_escrow_agent, only: [:show, :edit, :update, :destroy]
	respond_to :html, :xml, :json

	def show
		respond_with(@escrow_agent)
	end

	def new
		@escrow_agent = EscrowAgent.new
		respond_with(@escrow_agent)
	end


	def create
		@escrow_agent = EscrowAgent.find_by(escrow_agent_params)
		if @escrow_agent.nil?
			@escrow_agent = EscrowAgent.new(escrow_agent_params, without_protection: true)
			if @escrow_agent.valid?
				@escrow_agent.save
			else
				render :json => { error: 'Escrow Agent Not saved', success: false, "errors" => @escrow_agent.errors.full_messages}, status: :not_acceptable 
				return
			end
		end
		respond_with(@escrow_agent)
	end

	def agent_name
    search = "#{params[:term]}%"
    render json: 
      EscrowAgent.where("name like ?", search).limit(10).map(&:name)
  end

  def agent_addr
    search = "#{params[:term]}%"
    render json: 
      EscrowAgent.where("address like ?", search).limit(10).map(&:address)
  end

  def agent_city
    search = "#{params[:term]}%"
    render json: 
      EscrowAgent.where("city like ?", search).limit(10).map(&:city)
  end

  def agent_state
    search = "#{params[:term]}%"
    render json: 
      EscrowAgent.where("state like ?", search).limit(10).map(&:state)
  end

  def agent_zip
    search = "#{params[:term]}%"
    render json: 
      EscrowAgent.where("zip_code like ?", search).limit(10).map(&:zip_code)
  end

	private
		def set_escrow_agent
			@escrow_agent = EscrowAgent.find(params[:id])
		end

		def escrow_agent_params
			params.require(:escrow_agent).permit(:name, :address, :city, :state, :zip_code)
		end
	
end
