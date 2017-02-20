require 'sinatra/base'
require 'stickler/middleware'
require 'stickler/middleware/local'
require 'stickler/repository/local'

module Stickler::Middleware
  #
  # A rack middleware for implementing the gemcutter api
  #
  # == Options
  #
  # <b>:serve_indexes</b>::   the same as the Index middleware
  #
  # <b>:repo_root</b>::       the same as the Local middleware
  #
  # The <b>:repo_root</b> option is required.
  #
  # == Usage
  #
  #   use Stickler::Middleware::Gemcutter, :repo_root => '/path/to/repository'
  #
  #   use Stickler::Middleware::Gemcutter, :repo_root => '/path/to/repository',
  #                                        :serve_indexes => true
  #
  #
  class Gemcutter < ::Stickler::Middleware::Local

    def initialize( app = nil, options = {}  )
      super( app, options )
    end

    # gemcutter push
    post '/api/v1/gems' do
      begin
        @repo.
        spec = @repo.add( request.body )
        logger.info( "Pushed #{spec.full_name}" )
        return spec.to_s
      rescue Stickler::Repository::Error => e
        logger.error( "Error adding #{spec.full_name} to repo : #{e}" )
        error( 500, "Error adding gem to repo: #{e}" )
      end
    end

    # gemcutter yank
    delete '/api/v1/gems/yank' do
      spec = Stickler::SpecLite.new( params[:gem_name], params[:version] )
      if s = @repo.yank( spec ) then
        logger.info( "Yanked #{spec.full_name}" )
        return "Yanked #{spec.full_name}"
      else
        logger.warn( "Did not Yank #{spec.full_name}" )
        error( 503, "Did not Yank #{spec.to_s}" )
      end
    end

    # direct delete
    delete %r{\A/gems/((.*?)-([0-9.]+)(-.*?)?)\.gem\Z} do
      full_name, name, version, platform = *params[:captures]
      spec = Stickler::SpecLite.new( name, version, platform )
      @repo.delete( spec )
      logger.info( "Deleted #{spec.full_name}" )
      return "deleted gem #{spec.full_name}"
    end
  end
end


