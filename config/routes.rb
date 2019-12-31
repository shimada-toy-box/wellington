# frozen_string_literal: true

# Copyright 2019 Andrew Esler (ajesler)
# Copyright 2019 Matthew B. Gray
# Copyright 2019 Steven C Hartley
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "sidekiq/web"
require "sidekiq-scheduler/web"

# For more information about routes, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  root to: "landing#index"

  # Sidekiq is our jobs server and keeps tabs on backround tasks
  if Rails.env.development?
    # On development, mount without username/password
    mount Sidekiq::Web, at: "/sidekiq"
  elsif ENV["SIDEKIQ_USER"].present? && ENV["SIDEKIQ_PASSWORD"].present?
    # On production, only mount sidekiq if it's password protected
    mount Sidekiq::Web, at: "/sidekiq"

    Sidekiq::Web.use Rack::Auth::Basic  do |username, password|
      user_provided = ::Digest::SHA256.hexdigest(username)
      user_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_USER"])

      password_provided = ::Digest::SHA256.hexdigest(password)
      password_expected = ::Digest::SHA256.hexdigest(ENV["SIDEKIQ_PASSWORD"])

      ActiveSupport::SecurityUtils.secure_compare(user_provided, user_expected) &&
        ActiveSupport::SecurityUtils.secure_compare(password_provided, password_expected)
    end
  end

  # Sets routes for account management actions.
  # This order seems to matter for tests.
  devise_for :users
  devise_for :supports

  get "/login/:email/:key", to: "user_tokens#kansa_login_link", email: /[^\/]+/, key: /[^\/]+/
  resources :user_tokens, only: [:new, :show, :create], id: /[^\/]+/ do
    get :logout, on: :collection
  end

  resources :categories
  resources :credits
  resources :landing
  resources :memberships
  resources :themes
  resources :upgrades

  resources :reservations do
    resources :charges
    resources :nominations, id: /[^\/]+/
    resources :upgrades
  end

  # /operator are maintenance routes for support people
  scope :operator do
    resources :reservations do
      resources :credits
      resources :set_memberships
      resources :transfers, id: /[^\/]+/
    end
  end

  namespace :kiosk do
    root to: "memberships#index"

    resources :memberships, only: :index
    resources :reservations, only: [:new, :create] do
      resources :next_steps, only: :index
      resources :charges, only: [:new, :create]
    end
  end
end
