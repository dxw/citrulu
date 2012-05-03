module RSpreedly

  class Subscriber < Base

    def update_attributes(attrs)
      self.attributes= attrs
      update
    end
  
    # Change the subscription plan of a subscriber
    # PUT /api/v4/[short site name]/subscribers/[subscriber id]/change_subscription_plan.xml
    def change_subscription_plan(plan_id)
      new_plan = RSpreedly::SubscriptionPlan.new(:id => plan_id)
      !! api_request(:put, "/subscribers/#{self.customer_id}/change_subscription_plan.xml", :body => new_plan.to_xml)
    end
  
  end
  
end