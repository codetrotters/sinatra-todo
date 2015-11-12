require 'sinatra/base'

module Sinatra
  module Auth

    #Define Helper methods
    module Helpers
      def authorized?
        session[:authorized] || false
      end

      def authorize( user )
        #TODO: NOT Implemented yet
        session[:authorized] = true
      end

      def protected!
        redirect options.login_url unless authorized?
      end

      def logout!( redirect = true )
        session[:authorized] = false
        redirect options.login_url if redirect
      end
    end


    #Configure Application
    def self.registered(app)

      #Define Helpers on application
      app.helpers Auth::Helpers

      #Set default configuration
      app.set    :login_url, '/login'

      #Make sure sessions are enabled
      app.enable :sessions
    end

  end

  #Register Module with Sinatra
  register Auth

end
