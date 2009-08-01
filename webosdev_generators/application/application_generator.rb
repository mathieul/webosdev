class ApplicationGenerator < RubiGen::Base

  DEFAULT_SHEBANG = File.join(Config::CONFIG['bindir'],
                              Config::CONFIG['ruby_install_name'])

  attr_reader :application_name, :application_id, :application_vendor

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    @destination_root = File.expand_path(args.shift)
    @application_name = base_name
    extract_options
  end

  def manifest
    record do |m|
      # Ensure appropriate folder(s) exists
      m.directory ''
      BASEDIRS.each { |path| m.directory path }

      m.file_copy_each %w(app/assistants/stage-assistant.js icon.png sources.json)
      m.template_copy_each %w(appinfo.json index.haml)
      m.template "stylesheets/application.sass", "stylesheets/#{application_name}.sass"
      # 
      # m.dependency "install_rubigen_scripts", [destination_root, 'application'],
      #   :shebang => options[:shebang], :collision => :force
    end
  end

  protected
    def banner
      <<-EOS
Creates a new WebOS application using Haml and Sass.

USAGE: #{spec.name} name
EOS
    end

    def add_options!(opts)
      opts.separator ''
      opts.separator 'Options:'
      opts.on("-e", "--vendor NAME", "Vendor name.") { |vendor| options[:vendor] = vendor }
      opts.on("-v", "--version", "Show the #{File.basename($0)} version number and quit.")
    end

    def extract_options
      # for each option, extract it into a local variable (and create an "attr_reader :author" at the top)
      # Templates can access these value via the attr_reader-generated methods, but not the
      # raw instance variable value.
      @application_vendor = options[:vendor]
      @application_id = "com.#{@application_vendor.gsub(/ /, '_').downcase}.#{application_name}"
    end

    # Installation skeleton.  Intermediate directories are automatically
    # created so don't sweat their absence here.
    BASEDIRS = %w(
      app/assistants
      app/views
      images
      stylesheets
    )
end