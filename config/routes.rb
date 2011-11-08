Foreman::Application.routes.draw do
  root :to => 'dashboard#index'
  #ENC requests goes here
  match "node/:name" => 'hosts#externalNodes', :constraints => { :name => /[^\.][\w\.-]+/ }

  resources :reports do
    collection do
      get 'auto_complete_search'
    end
  end

  match ':controller/help', :action => 'welcome', :as => "help"
  constraints(:id => /[^\/]+/) do
    resources :hosts do
      member do
        get 'clone'
        get 'storeconfig_klasses'
        get 'externalNodes'
        get 'setBuild'
        get 'cancelBuild'
        get 'puppetrun'
        get 'pxe_config'
        put 'toggle_manage'
        post 'environment_selected'
        post 'architecture_selected'
        post 'os_selected'
      end
      collection do
        get 'show_search'
        get 'multiple_actions'
        get 'multiple_parameters'
        post 'update_multiple_parameters'
        get 'select_multiple_hostgroup'
        post 'update_multiple_hostgroup'
        get 'select_multiple_environment'
        post 'update_multiple_environment'
        get 'multiple_destroy'
        post 'submit_multiple_destroy'
        get 'multiple_build'
        post 'submit_multiple_build'
        get 'reset_multiple'
        get 'multiple_disable'
        post 'submit_multiple_disable'
        get 'multiple_enable'
        post 'submit_multiple_enable'
        get 'auto_complete_search'
        get 'template_used'
        get 'query' # Legacy query interface
        get 'active'
        get 'out_of_sync'
        get 'errors'
        get 'disabled'
        post 'process_hostgroup'
      end

      constraints(:host_id => /[^\/]+/) do
        resources :reports       ,:only => [:index, :show]
        resources :facts         ,:only => :index, :controller => :fact_values
        resources :puppetclasses ,:only => :index
        resources :lookup_keys   ,:only => :show
      end
    end

    resources :bookmarks, :except => [:show]
    resources :lookup_keys, :except => [:new, :create] do
      resources :lookup_values, :only => [:index, :create, :update, :destroy]
    end

    resources :facts, :only => [:index, :show] do
      constraints(:id => /[^\/]+/) do
        resources :values, :only => :index, :controller => :fact_values, :as => "host_fact_values"
      end
    end

    resources :hypervisors do
      constraints(:id => /[^\/]+/) do
        resources :guests, :controller => "Hypervisors::Guests", :except => [:edit] do
          member do
            put 'power'
          end
        end
      end
    end if SETTINGS[:libvirt]
  end

  resources :settings, :only => [:index, :update]
  resources :common_parameters do
    collection do
      get 'auto_complete_search'
    end
  end
  resources :environments do
    collection do
      get 'import_environments'
      post 'obsolete_and_new'
      get 'auto_complete_search'
    end
  end

  resources :hostgroups do
    member do
      get 'nest'
      get 'clone'
    end
    collection do
      get 'auto_complete_search'
    end
  end

  resources :puppetclasses do
    member do
      post 'assign'
    end
    collection do
      get 'import_environments'
      get 'auto_complete_search'
    end
    constraints(:id => /[^\/]+/) do
      resources :hosts
      resources :lookup_keys, :except => [:show, :new, :create]
    end
  end

  resources :smart_proxies, :except => [:show] do
    constraints(:id => /[^\/]+/) do
      resources :puppetca, :controller => "SmartProxies::Puppetca", :only => [:index, :update, :destroy]
      resources :autosign, :controller => "SmartProxies::Autosign", :only => [:index, :new, :create, :destroy]
    end
  end

  resources :fact_values, :only => [:create, :index] do
    collection do
      get 'auto_complete_search'
    end
  end

  resources :notices, :only => :destroy
  resources :audits do
    collection do
      get 'auto_complete_search'
    end
  end

  if SETTINGS[:login]
    resources :usergroups
    resources :users do
      collection do
        get 'login'
        post 'login'
        get 'logout'
        get 'auth_source_selected'
        get 'auto_complete_search'
      end
    end
    resources :roles do
      collection do
        get 'report'
        post 'report'
        get 'auto_complete_search'
      end
    end

    resources :auth_source_ldaps
  end

  if SETTINGS[:unattended]
    constraints(:id => /[^\/]+/) do
      resources :domains do
        collection do
          get 'auto_complete_search'
        end
      end
      resources :config_templates, :except => [:show] do
        collection do
          get 'auto_complete_search'
        end
      end
    end

    resources :operatingsystems do
      member do
        get 'bootfiles'
      end
      collection do
        get 'auto_complete_search'
      end
    end
    resources :media do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :models do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :architectures do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :ptables do
      collection do
        get 'auto_complete_search'
      end
    end

    resources :subnets, :except => [:show] do
      collection do
        get 'auto_complete_search'
        get 'import'
        post 'create_multiple'
      end
    end

    match 'unattended/template/:id/:hostgroup', :to => "unattended#template"
  end

  match 'dashboard', :to => 'dashboard#index', :as => "dashboard"
  match 'dashboard/auto_completer', :to => 'hosts#auto_complete_search', :as => "dashboard_auto_completer"
  match 'statistics', :to => 'statistics#index', :as => "statistics"



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

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'

end
