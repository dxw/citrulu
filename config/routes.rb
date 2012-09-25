SimpleFrontEndTesting::Application.routes.draw do

  ActiveAdmin.routes(self)

  mount Resque::Server, :at => "/resque"

  devise_for :admin_users, ActiveAdmin::Devise.config
 

  # Force redirect of users/sign_up to the root - for analytics consistency (?)
  match 'users/sign_up' => redirect("/")
  
  devise_for :users, :controllers => { :registrations => "registrations", :confirmations => "confirmations", :sessions => "sessions" }
    
  # This needs to go BEFORE the resources, otherwise it gets interpreted as PUT /test_files/id (i.e. update)
  match '/test_files/update_name/:id' => "test_files#update_name", :via => :put
  match '/test_files/update_run_status' => "test_files#update_run_status", :via => :put
  match '/test_files/create_first_test_file' => "test_files#create_first_test_file", :via => :post
  
  match '/test_files/update_liveview' => "test_files#update_liveview", :via => :post
  
  resources :test_files, :only => [:index, :create, :destroy, :edit, :update]
  resources :test_runs, :only => [:index, :show]
  resources :responses, :only => [:show]


  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
#  scope module: :v1 do
        resources :test_files
#     end
    end
  end

  # :destroy adds an :id param that we don't actually need. I can't see how to get rid of that.
  resources :token_authentications, :only => [:create, :destroy]

  get "payments/choose_plan"
  match "payments/choose_plan" => "payments#change_plan", :via => :put
  get "payments/change_plan_confirmation"
  get "payments/new"  
  match "payments/new" => "payments#create", :via => :post
  get "payments/confirmation"
  get "payments/edit"
  match "payments/edit" => "payments#update", :via => :put
  get "payments/update_confirmation"
  match "payments/destroy" => "payments#destroy", :via => :delete
  get "payments/cancel_confirmation"

  # Website pages routes:
  match 'terms' => "website#terms"
  match 'features' => "website#features"
  match 'info' => "website#info"
  match 'email' => "website#email"
  match 'agencies' => "website#agencies"
  match 'wordpress' => "website#wordpress"
  
  authenticated :user do
    root :to => redirect('/test_files')
  end
  
  devise_scope :user do
    match 'sign_up' => redirect("/")
    match 'sign_in' => redirect("/users/sign_in")
    match 'settings' => redirect("/users/edit")
    # This is the root route:
    root :to => "registrations#new"
  end
  
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
