Whoot::Application.routes.draw do

  # redirect to www.example.com if user goes to example.com
  match '(*any)' => redirect { |p, req| req.url.sub('www.', '') }, :constraints => { :host => /^www\./ }

  scope 'api' do
    scope 'v2' do
      scope 'posts' do
        get 'feed' => 'api_posts#feed', :defaults => { :format => :api }
        get ':id' => 'api_posts#show', :defaults => { :format => :api }
        post '' => 'api_posts#create', :defaults => { :format => :api }

        scope 'loop_ins' do
          post '' => 'api_loop_ins#create', :type => 'User', :defaults => { :format => :api }
          delete '' => 'api_loop_ins#destroy', :type => 'User', :defaults => { :format => :api }
        end
      end

      scope 'users' do
        scope 'follows' do
          post '' => 'api_follows#create', :type => 'User', :defaults => { :format => :api }
          delete '' => 'api_follows#destroy', :type => 'User', :defaults => { :format => :api }
        end

        scope 'blocked' do
          post '' => 'api_users#block_user', :defaults => { :format => :api }
          get '' => 'api_users#blocked_users', :defaults => { :format => :api }
          delete '' => 'api_users#unblock_user', :defaults => { :format => :api }
        end

        put '' => 'api_users#update', :defaults => { :format => :api }
        scope 'pings' do
          post '' => 'api_pings#create', :type => 'User', :defaults => { :format => :api }
        end

        get 'me' => 'api_users#me', :defaults => { :format => :api }
        get 'undecided' => 'api_users#undecided', :defaults => { :format => :api }
        get 'notifications' => 'api_users#notifications', :defaults => { :format => :api }
        put ':id/location' => 'api_users#change_location', :defaults => { :format => :api }
        get ':id/activity' => 'api_users#activity', :defaults => { :format => :api }
        get ':id/following_users' => 'api_users#following_users', :defaults => { :format => :api }
        get ':id/followers' => 'api_users#followers', :defaults => { :format => :api }
        get ':id' => 'api_users#show', :defaults => { :format => :api }
      end

      scope 'comments' do
        post '' => 'api_comments#create', :as => :comments_create, :defaults => { :format => :api }
      end

      scope 'invites' do
        post 'phone_numbers' => 'invites#invite_phone_numbers', :defaults => { :format => :api }
        get 'show_invite_screen' => 'invites#show_invite_screen', :defaults => { :format => :api }
      end

      scope 'shouts' do
        post '' => 'shouts#create', :defaults => { :format => :api }
      end

      get 'facebook-friends' => 'api#facebook_friends', :defaults => { :format => :api }
      get 'analytics' => 'api_users#analytics', :as => :analytics, :defaults => { :format => :api }
      get 'generate_token' => 'api#generate_token', :as => :mobile_generate_token, :defaults => { :format => :api }
      post 'set_device_token' => 'api#set_device_token', :as => :set_device_token, :defaults => { :format => :api }
    end

    scope 'v1' do
      get 'generate_token' => 'api#generate_token', :as => :mobile_generate_token, :defaults => { :format => :api }
      post 'set_device_token' => 'api#set_device_token', :as => :set_device_token, :defaults => { :format => :api }
      get 'posts' => 'api#posts', :defaults => { :format => :api }
      post 'posts' => 'posts#create', :defaults => { :format => :api }
      get 'posts/:id/comments' => 'api#comments', :defaults => { :format => :api }
      post 'posts/comments' => 'comments#create', :defaults => { :format => :api }
      get 'posts/:id/votes' => 'api#votes', :defaults => { :format => :api }
      post 'posts/votes' => 'votes#create', :defaults => { :format => :api }
      post 'follow' => 'follows#create', :defaults => { :format => :api }
      delete 'follow' => 'follows#destroy', :defaults => { :format => :api }
      post 'ping' => 'pings#create', :defaults => { :format => :api }
      get 'undecided' => 'api#undecided', :defaults => { :format => :api }
      get 'facebook-friends' => 'api#facebook_friends', :defaults => { :format => :api }
      get 'users/me' => 'api#me', :defaults => { :format => :api }
      get 'users/:id/following' => 'users#following_users', :defaults => { :format => :api }
      get 'users/:id/followers' => 'users#followers', :defaults => { :format => :api }
      get 'users/:id' => 'users#show', :defaults => { :format => :api }
      post 'invites/phone_numbers' => 'invites#invite_phone_numbers', :defaults => { :format => :api }
      get 'invites/show_invite_screen' => 'invites#show_invite_screen', :defaults => { :format => :api }
    end
  end

  # Users
  get 'settings' => 'users#settings', :as => :user_settings
  devise_for :users, :controllers => { :omniauth_callbacks => "omniauth_callbacks" }
  #omniauth passthrough (https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview)
  get '/users/auth/:provider' => 'omniauth_callbacks#passthru'

  scope "/users" do
    put "/picture" => "users#picture_update", :as => :user_picture_update
    get ':id/picture' => 'users#default_picture', :as => :user_default_picture
    put '/location' => 'users#change_location', :as => :user_change_location
  end

  get ':id/following' => 'users#show', :as => :user_following_users
  get ':id/followers' => 'users#show', :as => :user_followers

  resque_constraint = lambda do |request|
    request.env['warden'].authenticate? and request.env['warden'].user.role?('admin')
  end

  # Resque admin
  constraints resque_constraint do
    mount Resque::Server, :at => "admin/resque"
  end

  # Soulmate api
  mount Soulmate::Server, :at => "soul-data"

  # Invites
  resources :invites, :only => [:create, :index]

  # Posts
  resources :posts, :only => [:new]

  get ':id' => 'users#show', :as => :user

  # Pages
  scope 'pages' do
    get 'about' => 'pages#about', :as => :about
    get 'contact' => 'pages#contact', :as => :contact
    get 'terms' => 'pages#terms', :as => :terms
    get 'privacy' => 'pages#privacy', :as => :privacy
    get 'faq' => 'pages#faq', :as => :faq
    get 'team' => 'pages#team', :as => :team
  end

  root :to => "pages#home"



























  ## Posts
  #scope 'posts' do
  #  get 'map' => 'posts#map', :as => :post_map
  #  get 'ajax' => 'posts#ajax', :as => :posts_ajax
  #end
  #
  ## Venues
  #get 'venues/ac' => 'venues#autocomplete', :as => :venue_autocomplete
  #get 'venues/:id/attending' => 'venues#attending', :as => :venue_attending
  #resources :venues
  #
  ## Feed filters
  #put 'feed/display' => 'posts#update_feed_display', :as => :feed_display
  #put 'feed/sort' => 'posts#update_feed_sort', :as => :feed_sort
  #
  ## Following
  #post   'follow' => 'follows#create', :as => :user_follow_create
  #delete 'follow' => 'follows#destroy', :as => :user_follow_destroy
  #get    'venue/:id/attending/following' => 'venues#attending_venue_map', :as => :attending_venue_map
  #
  ## Notifications
  #get    'notifications/my' => 'notifications#my_notifications', :as => :my_notifications
  #
  ## Pinging
  #post   'ping' => 'pings#create', :as => :ping_create
  #
  ## Lists
  #post 'lists/:id/users' => 'lists#add_user', :as => :list_add_user
  #delete 'lists/:id/users' => 'lists#remove_user', :as => :list_remove_user
  #resources :lists
  #
  ## Voting
  #post   'vote' => 'votes#create', :as => :vote_create
  #delete 'vote' => 'votes#destroy', :as => :vote_destroy
  #scope 'votes' do
  #  get 'ajax' => 'votes#ajax', :as => :votes_ajax
  #end
  #
  ## Comments
  #scope 'comments' do
  #  get 'ajax' => 'comments#ajax', :as => :comments_ajax
  #end
  #resources :comments, :only => [:create, :destroy]
  #
  ## Uploads
  #match "/upload" => "uploads#create", :as => :upload_tmp
  #
  ## Testing
  #get 'testing' => 'testing#test', :as => :test
  #
  ## Tags
  #put 'tags/:id/make_trendable' => 'tags#make_trendable', :as => :tag_make_trendable
  #put 'tags/:id/make_stopword' => 'tags#make_stopword', :as => :tag_make_stopword
  #
  ## Twitter
  #post 'twitter/tweet' => 'users#tweet', :as => :tweet_post

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
