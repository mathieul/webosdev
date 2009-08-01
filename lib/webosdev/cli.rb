require 'optparse'

module Webosdev
  class CLI
    def self.execute(stdout, arguments=[])
      options = {
      }
      mandatory_options = %w(command)

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is a tool to help with developing WebOS applications
          with using tools such as Haml and Sass.

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-n", "--name NAME", String,
                "Name to use for the command (application, scene, etc...).") { |name| options[:name] = name }
        opts.on("-v", "--vendor NAME", String,
                "Name of the vendor.") { |name| options[:vendor] = name }
        commands = PalmManager::COMMANDS
        opts.on("-c", "--command COMMAND", String, commands,
                "Command to run (#{commands.join(", ")}).") { |command| options[:command] = command }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && missing = mandatory_options.find { |option| options[option.to_sym].nil? }
          STDERR.puts "Please specify the #{missing}.\n\n"
          stdout.puts opts; exit
        end
      end
      
      manager = PalmManager.new
      message = manager.send(options[:command].to_sym, options)
      stdout.puts "#{message}."
    end
  end
end