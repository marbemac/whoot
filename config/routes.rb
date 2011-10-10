Whoot::Application.routes.draw do

  # Invite Posts
  resources :invite_posts

  # Normal Posts
  get 'normal_posts/map' => 'normal_posts#map', :as => :normal_post_map
  resources :normal_posts

  # Venues
  get 'venues/ac' => 'venues#autocomplete', :as => :venue_autocomplete
  get 'venues/:id/attending' => 'venues#attending', :as => :venue_attending
  resources :venues

  # Feed filters
  put 'feed/display' => 'posts#update_feed_display', :as => :feed_display
  put 'feed/sort' => 'posts#update_feed_sort', :as => :feed_sort

  # Following
  post   'follow' => 'follows#create', :as => :user_follow_create
  delete 'follow' => 'follows#destroy', :as => :user_follow_destroy
  get    'venue/:id/attending/following' => 'venues#attending_venue_map', :as => :attending_venue_map

  # Invites
  resources :invites, :only => [:create]

  # Notifications
  get    'notifications/my' => 'notifications#my_notifications', :as => :my_notifications

  # Pinging
  post   'ping' => 'pings#create', :as => :ping_create

  # Lists
  post 'lists/:id/users' => 'lists#add_user', :as => :list_add_user
  delete 'lists/:id/users' => 'lists#remove_user', :as => :list_remove_user
  resources :lists

  # Attending
  post   'attend' => 'attends#create', :as => :invite_attend_create
  delete 'attend' => 'attends#destroy', :as => :invite_attend_destroy

  # Voting
  post   'vote' => 'votes#create', :as => :vote_create
  delete 'vote' => 'votes#destroy', :as => :vote_destroy

  # Comments
  resources :comments, :only => :create

  # Uploads
  match "/upload" => "uploads#create", :as => :upload_tmp

  # Tags
  put 'tags/:id/make_trendable' => 'tags#make_trendable', :as => :tag_make_trendable
  put 'tags/:id/make_stopword' => 'tags#make_stopword', :as => :tag_make_stopword

  # Resque admin
  mount Resque::Server, :at => "/resque"

  scope "/users" do
    get 'ac' => 'users#autocomplete', :as => :user_autocomplete
    get ':id/following' => 'users#following_users', :as => :user_following_users
    get ':id/followers' => 'users#followers', :as => :user_followers
    get ':id/hover' => 'users#hover' , :as => :user_hover
  end

  ActiveAdmin.routes(self)
  resources :users, :only => :show
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }

  root :to => "pages#home"

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
