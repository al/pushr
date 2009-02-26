require 'rake'
require 'yaml'

CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml')) unless defined? CONFIG
DEFAULT_PORT = 4000

# -- Shortcuts

desc "Start application in development mode under thin on port #{DEFAULT_PORT}"
task :default => 'start:development'

desc "Start application in deployment mode under thin on port #{DEFAULT_PORT}"
task :start => 'start:deployment'

desc "Stop the deployment mode application under thin on port #{DEFAULT_PORT}"
task :stop => 'stop:deployment'

# -- Start/Stop

namespace :start do
  desc "Start application in development mode on the specified port (default: #{DEFAULT_PORT})"
  task :development, [:port] do |t, args|
    args.with_defaults(:port => DEFAULT_PORT)
    system "ruby pushr.rb -p #{args.port}"
  end

  desc "Start application in deployment mode under the specified server (default: thin) on the specified port (default: #{DEFAULT_PORT})"
  task :deployment, [:server_type, :port] do |t, args|
    args.with_defaults(:server_type => 'thin', :port => DEFAULT_PORT)
    case args.server_type
      when 'mongrel', 'thin', 'webrick':
        system "rackup config.ru --server #{args.server_type} --port #{args.port} --daemonize --env deployment --pid tmp/pids/#{args.server_type}_#{args.port}.pid"
        puts ($?.success? ? "> Pushr started on port #{args.port}" : "> Failed to start Pushr")
      else
        puts '> Unsupported server'
    end
  end
end

namespace :stop do
  desc "Stop the deployment mode application running under the specified server (default: thin) on the specified port (default: #{DEFAULT_PORT})"
  task :deployment, [:server_type, :port] do |t, args|
    args.with_defaults(:server_type => 'thin', :port => DEFAULT_PORT)
    case args.server_type
      when 'mongrel', 'thin', 'webrick':
        system "kill -9 `cat tmp/pids/#{args.server_type}_#{args.port}.pid`; rm tmp/pids/#{args.server_type}_#{args.port}.pid"
        puts ($?.success? ? "> Pushr stopped" : "> Failed to stop Pushr. Perhaps it has already stopped? If so use rake tmp:pids:clear to delete all pids in tmp/pids")
      else
        puts '> Unsupported server'
    end
  end
end

# -- Maintenance

namespace :app do
  desc "Check dependencies of the application"
  task :check do
    begin
      require 'rubygems'
      require 'sinatra'
      require 'haml'
      require 'sass'
      require 'capistrano'
      begin
        require 'thin'
      rescue LoadError => e
        begin
          require 'mongrel'
        rescue LoadError => e
          begin
            require 'webrick'
          rescue LoadError => e
            raise LoadError.new('thin/mongrel/webrick')
          end
        end
      end
      require 'highline'
      puts '[*] Good! You seem to have all the neccessary gems for Pushr'
    rescue LoadError => e
      puts "[!] Bad! Missing gem #{e.message.match(/([^ ]*)$/)[0]}"
    ensure
      Sinatra::Default.set(:run, false)
    end
  end

  desc 'Add a local public key to ~/.ssh/authorized_keys2 (so Capistrano can SSH to localhost)'
  task :add_public_key_to_localhost do
    require "highline/import"
    public_key = ask('Which public key do you want to use?') do |q|
      q.default = '~/.ssh/id_rsa.pub'
      q.validate = lambda { |file| !FileTest.exists?(file) }
      q.responses[:not_valid] = 'File does not exist'
    end
    `cat #{public_key} >> ~/.ssh/authorized_keys2`
  end
end

namespace :tmp do
  namespace :pids do
    desc 'Clear all files in tmp/pids'
    task :clear do
      FileUtils.rm(Dir['tmp/pids/[^.]*'])
    end
  end
end

namespace :log do
  desc 'Clear all files in log'
  task :clear do
    FileUtils.rm(Dir['log/[^.]*'])
  end
end