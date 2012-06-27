class DealsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
    @deals = Deal.all
  end
  
  def show
    @deal = Deal.find(params[:id])
  end
  
  def new
    @deal = Deal.new
    if params[:company_id].present?
      @deal.dealable = Company.find(params[:company_id])
    end
    if params[:person_id].present?
      @deal.dealable = Person.find(params[:person_id])
    end    
  end
  
  def edit
    @deal = Deal.find(params[:id])
  end
  
  def create
    @deal = Deal.new(params[:deal])
    
    if @deal.save
      redirect_to @deal, notice: 'Deal was successfully created.'
    else
      render "new"
    end  
  end
  
  def update
    @deal = Deal.find(params[:id])

    if @deal.update_attributes(params[:deal])
      redirect_to @deal, notice: 'Deal was successfully updated.'
    else
      render "edit"
    end
  end
  
  def add_participant
    @deal = Deal.find(params[:deal_id])
    @deal.add_participant(params[:participant])
    redirect_to deal_path(@deal, anchor: "participants")
  end
end