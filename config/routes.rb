Spree::Core::Engine.routes.draw do
  namespace :admin do
    resources :reports, :only => [] do
      collection do
        get   :out_of_stock
        post   :out_of_stock
      end
    end
  end
end
