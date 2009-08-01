require "json"

class SceneGenerator < RubiGen::Base

  attr_reader :name, :title

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path('.')
    @name = args.shift
    @title = @name.split('-').map { |n| n.capitalize}.join
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory 'app/assistants'
      m.directory "app/views/#{name}"
      m.template "app/assistants/name-assistant.js", "app/assistants/#{name}-assistant.js"
      m.template "app/views/name/name-scene.haml", "app/views/#{name}/#{name}-scene.haml"
      m.gsub_file "sources.json", /\} *$/ do
        %Q(},\n    {\n        "scenes" : "#{name}",\n        "source" : "app\\/assistants\\/#{name}-assistant.js"\n    })
      end
    end
  end

  protected
    def banner
      <<-EOS
Creates a new WebOS scene.

USAGE: #{$0} #{spec.name} name
EOS
    end

    def add_options!(opts)
      # opts.separator ''
      # opts.separator 'Options:'
      # For each option below, place the default
      # at the top of the file next to "default_options"
      # opts.on("-a", "--author=\"Your Name\"", String,
      #         "Some comment about this option",
      #         "Default: none") { |o| options[:author] = o }
      # opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      # @author = options[:author]
    end
end