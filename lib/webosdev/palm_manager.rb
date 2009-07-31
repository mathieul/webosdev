%w(haml sass fileutils json).each { |mod| require mod }

class PalmManager
  DIRECTORIES = {:haml => %w(. ./app/*/*), :sass => %w(./stylesheets)}
  EXTENSIONS = {:haml => 'html', :sass => 'css'}
  APPINFO_FILE = './appinfo.json'
  
  Error = Class.new(RuntimeError)
  FileNotFoundError = Class.new(Error)
  ArgumentError = Class.new(Error)
  ExecutionError = Class.new(Error)
  
  def files_with_format(extension, options = {})
    raise ArgumentError, "Unknown extension" unless DIRECTORIES[extension]
    DIRECTORIES[extension].map do |directory|
      files = Dir["#{directory}/*.#{extension}"]
      files.map! {|name| name.sub(/\.#{extension}$/, ".#{EXTENSIONS[extension]}") } if options[:generated]
      files
    end.flatten.compact
  end
  
  def generated_name(name)
    match = /^(.*)\.([^.]+)/.match name
    return nil unless match
    ext = EXTENSIONS[match[2].to_sym]
    return nil unless ext
    "#{match[1]}.#{ext}"
  end
  
  def ipk_name
    "#{application_info['id']}_#{application_info['version']}_all.ipk"
  end

  def application_name
    @application_name ||= "#{application_info['id']}"
  end

  def application_info
    raise FileNotFoundError, "Can't find file #{APPINFO_FILE.inspect}" unless FileTest.exists?(APPINFO_FILE)
    @application_info ||= JSON.load(File.read(APPINFO_FILE))
  end
  
  def new_app(opts)
    res = %x(palm-generate #{opts[:application]} 2>&1)
    raise ExecutionError, res unless $?.success?
    "New application #{opts[:application].inspect} was created successfully"
  end
end