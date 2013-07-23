# encoding: utf-8
require 'rails/railtie'

module GdeposylkaApi

  class Railtie < ::Rails::Railtie #:nodoc:

    rake_tasks do
      load File.expand_path('../../tasks/parcels_manager.rake', __FILE__)
    end

  end # Railtie

end # GdeposylkaApi
