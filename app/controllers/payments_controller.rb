class PaymentsController < ApplicationController
  before_filter :authenticate_user!
    
  layout "logged_in"
  
  def choose_plan
    @names = Plan::LEVELS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES
  end

  def new
    redirect_if_active
    
    # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
      return
    end

    @plan = Plan.find(params[:plan_id])    
  end
  
  def create
    redirect_if_active
    
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
      return
    end
    
    @plan = Plan.find(params[:plan_id])
    
    # Create the subscriber on Spreedly:
    current_user.create_or_update_subscriber
    
    # Raise the invoice agaist that subscriber
    invoice = RSpreedly::Invoice.new(
      :subscription_plan_id => @plan.spreedly_id,
      :subscriber => current_user.subscriber
    )

    invoice.save! # Will go BOOM if there was a problem saving the invoice

    @credit_card = RSpreedly::PaymentMethod::CreditCard.new(params[:credit_card])

    if invoice.pay(@credit_card)
      current_user.plan = @plan
      current_user.status = :paid
      current_user.save
      
      redirect_to action: "confirmation"
    else
      @errors = invoice.errors
      render action: "new", plan_id: @plan.id
    end
  end
  
  def edit
    # Redirect if they don't have an active subscription
    unless current_user.status == :paid
      redirect_to "/"
      return
    end
  end
  
  def update
    @credit_card = RSpreedly::PaymentMethod::CreditCard.new(params[:credit_card])

    if current_user.update_subscription_details(payment_method: @credit_card)      
      redirect_to action: "update_confirmation"
    else
      # TODO: Handle error cases: http://spreedly.com/manual/integration-reference/update-subscriber
      @errors = invoice.errors
      render action: "edit"
    end
  end

  def confirmation 
    if current_user.active_subscriber?
      # N.B. We DON'T check here that the specific invoice raised as part of this flow was actually paid - 
      # that's delegated to upstream actions.
      @plan = current_user.plan
      @test_files = current_user.test_files
    else 
      # Normally this page will only be displayed when a payment has been successful and so the user will be active in Spreedly.
      # If they're not active in Spreedly, it must mean that they've tried to access this page directly when they don't have 
      # an active subscription, so we redirect them to the home page.
      redirect_to '/'
      return
    end
  end
  
  protected
  
  def redirect_if_active
    # We don't want users to be able to purchase multiple subscriptions, 
    # so if they already have an active subscription in Spreedly, redirect them    
    if current_user.active_subscriber?
      redirect_to "/"
    end
  end
  
end
