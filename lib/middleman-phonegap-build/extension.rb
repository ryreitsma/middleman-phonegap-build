# Require core library
require "middleman-core"

# Extension namespace
module Middleman
  module PhonegapBuild

    class Options < Struct.new(:deploy_method, :host, :port, :user, :password, :path, :clean, :remote, :branch, :build_before, :flags); end

    class << self

      def options
        @@options
      end

      def registered(app, options_hash={}, &block)
        options = Options.new(options_hash)
        yield options if block_given?

        options.build_before ||= false

        @@options = options

        app.send :include, Helpers
      end

      alias :included :registered

    end

    module Helpers
      def options
        ::Middleman::PhonegapBuild.options
      end
    end

  end
end
