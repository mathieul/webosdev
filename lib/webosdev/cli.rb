require 'optparse'

module Webosdev
  class CLI
    def self.execute(stdout, arguments=[])

      # NOTE: the option -p/--path= is given as an example, and should be replaced in your application.

      options = {
      }
      mandatory_options = %w(  )

      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER.gsub(/^          /,'')
          This application is a tool to help with developing WebOS applications
          with using tools such as Haml and Sass.

          Usage: #{File.basename($0)} [options]

          Options are:
        BANNER
        opts.separator ""
        opts.on("-a", "--application=NAME", String,
                "Name of the application.") { |name| options[:application] = name }
        opts.on("-h", "--help",
                "Show this help message.") { stdout.puts opts; exit }
        opts.parse!(arguments)

        if mandatory_options && mandatory_options.find { |option| options[option.to_sym].nil? }
          stdout.puts opts; exit
        end
      end
      
      tools = PalmTools.new

      application = options[:application] || tools.application_name
      raise "Unknown application" unless application

      # do stuff
      stdout.puts "application: #{application.inspect}"
    end
  end
end