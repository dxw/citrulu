class PaymentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_if_active, only: [:new, :create]
  before_filter :redirect_if_no_plan_selected, only: [:new, :create, :change_plan]
  before_filter :redirect_if_not_active, only: [:change_plan, :edit, :update, :confirmation, :update_confirmation, :destroy]
  
  layout "logged_in"
  
  # GET /change_plan
  def choose_plan
    @names = Plan::LEVELS
    @limits = Plan.limits
    @features = Plan.features
  end
  
  # PUT /change_plan
  def change_plan
    current_user.change_plan(params[:plan_id])
    redirect_to action: "change_plan_confirmation"
  end

  def new
    @plan = Plan.find(params[:plan_id])   
  end
  
  def create
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
      current_user.save!
      
      redirect_to action: "confirmation"
    else
      @errors = invoice.errors
      render action: "new", plan_id: @plan.id
    end
  end
  
  def update
    @credit_card = RSpreedly::PaymentMethod::CreditCard.new(params[:credit_card])
    
    subscriber = current_user.subscriber 
    
    if subscriber.update_attributes(payment_method: @credit_card)
      if status == :inactive
        current_user.status = :paid
        current_user.save!
      end
      redirect_to action: "update_confirmation"
    else
      @errors = subscriber.errors
      render action: "edit"
    end
  end
  
  # Cancel the user's subscription
  def destroy
    subscriber = current_user.subscriber
    
    if subscriber.stop_auto_renew
      current_user.status = :cancelled
      current_user.save!
      redirect_to action: "cancel_confirmation"
    else
      @errors = subscriber.errors
    end
  end
  
  protected
  
  # When buying a new plan, some pages require a plan to have been selected.
  def redirect_if_no_plan_selected
    if params[:plan_id].nil?
      redirect_to action: "choose_plan"
    end
  end
  
  # We don't want users to be able to purchase multiple subscriptions, 
  # so if they already have an active subscription in Spreedly, redirect them
  def redirect_if_active
    if current_user.status == :paid || current_user.status == :cancelled 
      redirect_to "/"
    end
  end
  
  # It makes no sense for a user to try and edit a subscription which isn't active!
  def redirect_if_not_active
    unless current_user.status == :paid
      redirect_to "/"
    end
  end
end
