KrAntenaFootball::Application.routes.draw do

# 要リファクタリング  
  get  "news/index"
  get  "news/get_todays_post"

  get  "site/index"
  get  "site/new"
  get  "site/update"
  put  "site/update"
  post "site/update"    
  get  "site/index_for_admin"
  get  "site/create_from_rank"
  get  "site/create_auto"
  get  "site/create_auto/:id" => "site#create_auto"
    
  get  "article/index"
  get  "article/sample"
  get  "article/create_from_rss"
  get  "article/update_share_count"
  get  "article/update_sns_count"  
  
  get  "entry/index"
  get  "entry/fetch"
  get  "entry/update_sns_count"
  get  "entry/get_sns_comments"
        
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
  # match ':controller(/:action(/:id))(.:format)'
end
