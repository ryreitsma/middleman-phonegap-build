require 'middleman-core/cli'

require 'middleman-phonegap-build/extension'
require 'middleman-phonegap-build/pkg-info'

module Middleman
  module Cli

    # This class provides a "phonegap_build" command for the middleman CLI.
    class PhonegapBuild < Thor
      include Thor::Actions

      check_unknown_options!

      namespace :phonegap_build

      # Tell Thor to exit with a nonzero exit code on failure
      def self.exit_on_failure?
        true
      end

      desc 'phonegap_build [options]', Middleman::PhonegapBuild::TAGLINE
      method_option 'build_before',
      :type => :boolean,
      :aliases => '-b',
      :desc => 'Run `middleman build` before the phonegap_build step'

      def phonegap_build
        if options.has_key? 'build_before'
          build_before = options.build_before
        else
          build_before = self.phonegap_build_options.build_before
        end
        if build_before
          # http://forum.middlemanapp.com/t/problem-with-the-build-task-in-an-extension
          run('middleman build') || exit(1)
        end
        send("deploy_#{self.phonegap_build_options.deploy_method}")
      end

      protected

      def print_usage_and_die(message)
        raise Error, 'ERROR: ' + message
      end

      def inst
        ::Middleman::Application.server.inst
      end

      def phonegap_build_options
        options = nil

        begin
          options = inst.options
        rescue NoMethodError
          print_usage_and_die 'You need to activate the phonegap_build extension in config.rb.'
        end

        unless options.deploy_method
          print_usage_and_die 'The phonegap_build extension requires you to set a deploy_method.'
        end

        case options.deploy_method
        when :sftp
          unless options.host && !options.path
            print_usage_and_die "The #{options.deploy_method} deploy_method requires host and path to be set."
          end
        when :ftp
           unless options.host && options.user && options.password && options.path
            print_usage_and_die 'The ftp phonegap_build deploy_method requires host, path, user, and password to be set.'
          end
        end

        options
      end

      def deploy_ftp
        require 'net/ftp'
        require 'ptools'

        host = self.phonegap_build_options.host
        user = self.phonegap_build_options.user
        pass = self.phonegap_build_options.password
        path = self.phonegap_build_options.path

        puts "## Deploying via ftp to #{user}@#{host}:#{path}"

        ftp = Net::FTP.new(host)
        ftp.login(user, pass)
        ftp.chdir(path)
        ftp.passive = true

        Dir.chdir(self.inst.build_dir) do
          files = Dir.glob('**/*', File::FNM_DOTMATCH)
          files.reject { |a| a =~ Regexp.new('\.$') }.each do |f|
            if File.directory?(f)
              begin
                ftp.mkdir(f)
                puts "Created directory #{f}"
              rescue
              end
            else
              begin
                if File.binary?(f)
                  ftp.putbinaryfile(f, f)
                else
                  ftp.puttextfile(f, f)
                end
              rescue Exception => e
                reply = e.message
                err_code = reply[0,3].to_i
                if err_code == 550
                  if File.binary?(f)
                    ftp.putbinaryfile(f, f)
                  else
                    ftp.puttextfile(f, f)
                  end
                end
              end
              puts "Copied #{f}"
            end
          end
        end
        ftp.close
      end

      def deploy_sftp
        require 'net/sftp'
        require 'ptools'

        host = self.phonegap_build_options.host
        user = self.phonegap_build_options.user
        pass = self.phonegap_build_options.password
        path = self.phonegap_build_options.path

        puts "## Deploying via sftp to #{user}@#{host}:#{path}"

        # `nil` is a valid value for user and/or pass.
        Net::SFTP.start(host, user, :password => pass) do |sftp|
          sftp.mkdir(path)
          Dir.chdir(self.inst.build_dir) do
            files = Dir.glob('**/*', File::FNM_DOTMATCH)
            files.reject { |a| a =~ Regexp.new('\.$') }.each do |f|
              if File.directory?(f)
                begin
                  sftp.mkdir("#{path}/#{f}")
                  puts "Created directory #{f}"
                rescue
                end
              else
                begin
                  sftp.upload(f, "#{path}/#{f}")
                rescue Exception => e
                  reply = e.message
                  err_code = reply[0,3].to_i
                  if err_code == 550
                    sftp.upload(f, "#{path}/#{f}")
                  end
                end
                puts "Copied #{f}"
              end
            end
          end
        end
      end
    end
  end
end
