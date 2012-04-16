class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  
  layout "logged_in"
  
  def choose_plan
    @names = Plan::NAMES
    @costs = Plan::COSTS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES
  end
  
  def set_plan
    # plan_name = Plan::NAMES(params[:plan_level].to_sym)
    plan_name = "Cornichon"
    plan = Plan.find_by_name_en(plan_name)
   
    redirect_to action: "new", plan_id: plan.id
  end

  def new
    # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
      return
    end
    
    @plan_id = params[:plan_id]
  end
  
  def create
    # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    if params[:plan_id].nil?
      redirect_to action: choose_plan
      return
    end

    plan = Plan.find(params[:plan_id])
    
    # Create the subscriber on Spreedly:
    current_user.create_or_update_subscriber
    
    # Raise the invoice agaist that subscriber
pp "INTERACTING WITH SPREEDLY: new invoice"
    invoice = RSpreedly::Invoice.new(
      :subscription_plan_id => plan.spreedly_id,
      :subscriber => current_user.subscriber
    )

    invoice.save! # Will go BOOM if there was a problem saving the invoice
pp "INTERACTING WITH SPREEDLY: credit card"
    payment = RSpreedly::PaymentMethod::CreditCard.new(params[:credit_card])
pp "INTERACTING WITH SPREEDLY: pay invoice"
    if invoice.pay(payment)
      current_user.plan = plan
      current_user.save
      
      redirect_to action: "confirmation"
    else
      @errors = invoice.errors
      render action: "new"
    end
  end

  def confirmation
    
  end
  
end
