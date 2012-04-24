class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_if_active
  
  layout "logged_in"
  
  def choose_plan
    @names = Plan::LEVELS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES
  end
  
  def set_plan   
    redirect_to action: "new", plan_id: params["plan_id"]
  end

  def new
    # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    return if reroute_if_accessed_directly

    @plan = Plan.find(params[:plan_id])    
  end
  
  def create
    return if reroute_if_accessed_directly
    
    plan = Plan.find(params[:plan_id])
    
    # Create the subscriber on Spreedly:
    current_user.create_or_update_subscriber
    
    # Raise the invoice agaist that subscriber
    invoice = RSpreedly::Invoice.new(
      :subscription_plan_id => plan.spreedly_id,
      :subscriber => current_user.subscriber
    )

    invoice.save! # Will go BOOM if there was a problem saving the invoice
    
    payment = RSpreedly::PaymentMethod::CreditCard.new(params[:credit_card])

    if invoice.pay(payment)
      current_user.plan = plan
      current_user.save
      
      redirect_to action: "confirmation"
    else
      @errors = invoice.errors
      @plan_id = params[:plan_id]
      render action: "new"
    end
  end

  def confirmation
    # Redirect the user to the home page if they have never subscribed
    subscriber = current_user.subscriber
    
    if subscriber
      invoices = subscriber.invoices
      unless invoices
        redirect_to '/'
        return
      end
    else
      redirect_to '/'
      return
    end
    
    @test_files = current_user.test_files
    
    subscriber = current_user.subscriber
    invoices = subscriber.invoices
    raise "Wrong number of invoices: #{invoices}" unless invoices.length == 1
    invoice = invoices.first
    raise "Wrong number of line items: #{line_items}" unless invoice.line_items.length == 1
    
    @line_item = invoice.line_items.first
    @subscription_plan_name = subscriber.subscription_plan_name
  end
  
  protected
  
  def reroute_if_accessed_directly
   # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
      return true
    end
    return false
  end
  
  def redirect_if_active
    # We don't want users to be able to purchase multiple subscriptions...
    # 'Active' means 'has a current subscription 
    if current_user.active?
      redirect_to "/"
    end
  end
  
end
