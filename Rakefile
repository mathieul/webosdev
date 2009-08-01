require 'rubygems'
gem 'hoe', '>= 2.1.0'
require 'hoe'
require 'fileutils'
require './lib/webosdev'

Hoe.plugin :newgem

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.spec 'webosdev' do
  self.developer 'Mathieu Lajugie', 'mathieul@gmail.com'
end

require 'newgem/tasks'
Dir['tasks/**/*.rake'].each { |t| load t }
