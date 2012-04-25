class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_if_active, :except => :confirmation
  
  layout "logged_in"
  
  def choose_plan
    @names = Plan::LEVELS
    @limits = Plan::LIMITS
    @features = Plan::FEATURES
  end

  def new
    # Redirect the user to the beginning of the payment flow if they tried to access this page directly
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
      return
    end

    @plan = Plan.find(params[:plan_id])    
  end
  
  def create
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
      current_user.active = true # Paying the invoice will have set them to active in Spreedly
      current_user.save
      
      redirect_to action: "confirmation"
    else
      @errors = invoice.errors
      render action: "new", plan_id: @plan.id
    end
  end

  def confirmation
    subscriber = current_user.subscriber
    
    if subscriber && subscriber.active
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
    subscriber = current_user.subscriber
    
    if subscriber && subscriber.active
      redirect_to "/"
    end
  end
  
end
