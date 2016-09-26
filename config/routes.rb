Rails.application.routes.draw do
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  resources :users do
    collection do
      get :invite
      post :send_invites, path: "send-invites"
    end
    member do
      put :activate
      put :deactivate
    end
  end

  resources :meals do
    collection do
      get :work
    end
    member do
      put :close
      put :reopen
      get :finalize
      put :do_finalize
      get :summary
    end
  end

  get "reservations(/:community(/:resource_id))" => "reservations#index",
    community: /[a-z][a-z0-9]?/, as: :reservations
  get "reservations/:community/:resource_id/new" => "reservations#new",
    community: /[a-z][a-z0-9]?/, as: :new_reservation
  resources :reservations, except: [:index, :new]

  resources :calendar_exports, only: [:index], path: "calendars" do
    member do
      # This is the show action, allowing paths to include the user's calendar token,
      # e.g. /calendars/meals/558327a88c6a2c635fac627dcdbc50f4
      get ":calendar_token", to: "calendar_exports#show", as: ""
    end
  end

  resources :signups

  resources :households do
    member do
      get :accounts
      put :activate
      put :deactivate
    end
  end

  resources :accounts, only: [:index, :show, :edit, :update] do
    collection do
      put :apply_late_fees
      put :apply_payments
    end
    resources :transactions
  end

  resources :statements, only: [:show] do
    collection do
      post :generate
      get :more
    end
  end

  get "ping", to: "landing#ping"
  get "inactive", to: "home#inactive"

  authenticated :user do
    root to: "meals#index", as: :authenticated_root
  end

  root to: "landing#index"
end
