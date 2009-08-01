%w(haml sass fileutils json).each { |mod| require mod }

class PalmManager
  DIRECTORIES = {:haml => %w(. ./app/*/*), :sass => %w(./stylesheets)}
  EXTENSIONS = {:haml => 'html', :sass => 'css'}
  APPINFO_FILE = './appinfo.json'
  GENERATOR_DIR = File.join(File.dirname(__FILE__), "../../webosdev_generators")
  COMMANDS = %w(application scene package install novacom)

  Error = Class.new(RuntimeError)
  FileNotFoundError = Class.new(Error)
  ArgumentError = Class.new(Error)
  ExecutionError = Class.new(Error)

  def ipk_name
    "#{application_info['id']}_#{application_info['version']}_all.ipk"
  end

  def application_name
    @application_name ||= "#{application_info['id']}"
  end

  def application_title
    @application_title ||= "#{application_info['title']}"
  end

  def application_info
    raise FileNotFoundError, "Can't find file #{APPINFO_FILE.inspect}" unless FileTest.exists?(APPINFO_FILE)
    @application_info ||= JSON.load(File.read(APPINFO_FILE))
  end
  
  def application(opts)
    raise ArgumentError, "Missing application name" unless opts[:name]
    vendor = opts[:vendor].split(' ')[0].downcase rescue 'vendor'
    require 'rubigen'
    require 'rubigen/scripts/generate'
    source = RubiGen::PathSource.new(:application, GENERATOR_DIR)
    RubiGen::Base.reset_sources
    RubiGen::Base.append_sources source
    RubiGen::Scripts::Generate.new.run(['-e', opts[:vendor], opts[:name]], :generator => 'application')
  end

  def scene(opts)
    require 'rubigen'
    require 'rubigen/scripts/generate'
    source = RubiGen::PathSource.new(:scene, GENERATOR_DIR)
    RubiGen::Base.reset_sources
    RubiGen::Base.append_sources source
    RubiGen::Scripts::Generate.new.run([opts[:name]], :generator => 'scene')
  end

  def package(opts)
    formats = [:haml, :sass]
    render_files(formats)
    res = %x(palm-package . 2>&1)
    raise ExecutionError, res unless $?.success?
    FileUtils.rm_f(files_with_formats(formats, :generated => true))
    "Application #{application_title} was successfully packaged to #{ipk_name}"
  end
  
  def install(opts)
    res = %x(palm-install #{ipk_name} 2>&1)
    raise ExecutionError, res unless $?.success?
    res = %x(palm-launch #{application_name} 2>&1)
    raise ExecutionError, res unless $?.success?
    "Application #{application_title} was installed and launched."
  end
  
  def novacom(opts)
    grep_novacomd = %x(ps -eo pid,command | grep novacomd | grep -v grep)
    if %x(ps -eo pid,command | grep novacomd | grep -v grep).empty?
      %x(nohup /opt/nova/bin/novacomd >/dev/null 2>&1 &)
      "Started the novacomd daemon"
    else
      "The novacomd daemon is already running"
    end
  end

  private
  def render_files(*formats)
    # render files for each format (:haml, :sass)
    formats.flatten.each do |format|
      format_name = capitalize_string(format.to_s)
      files_with_formats(format).each do |name|
        the_module = Object.const_get(format_name)
        engine = the_module::Engine.new(File.read(name))
        content = engine.render
        File.open(generated_name(name), "w") { |file| file.write(content) }
      end
      puts "Rendered #{format_name} files."
    end
  end

  def files_with_formats(*extensions)
    options = extensions.last.is_a?(Hash) ? extensions.pop : {}
    result = []
    extensions.flatten.each do |extension|
      raise ArgumentError, "Unknown extension" unless DIRECTORIES[extension]
      result << DIRECTORIES[extension].map do |directory|
        files = Dir["#{directory}/*.#{extension}"]
        files.map! {|name| name.sub(/\.#{extension}$/, ".#{EXTENSIONS[extension]}") } if options[:generated]
        files
      end
    end
    result.flatten.compact
  end

  def generated_name(name)
    match = /^(.*)\.([^.]+)/.match name
    return nil unless match
    ext = EXTENSIONS[match[2].to_sym]
    return nil unless ext
    "#{match[1]}.#{ext}"
  end

  def capitalize_string(string)
    (string.slice(0, 1) || '').upcase + (string.slice(1..-1) || '').downcase
  end
end