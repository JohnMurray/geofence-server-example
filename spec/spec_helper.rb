# require application files
$: << ::File.expand_path('../../src', __FILE__)
require 'app'
require 'geofence'

# at this point bundler should be setup and the :development group
# should have been included. However, just to be sure, I'm going to
# include bundler again and require the test group.
require 'bundler/setup'
Bundler.require(:test)

# require any helpers
d = File.join(File.expand_path('../', __FILE__), 'helpers', '*.rb')
Dir['helpers/*'].each {|f| require f}


# setup rspec the way we need it
RSpec.configure do |config|
  config.mock_framework = :rspec
  config.include Rack::Test::Methods
end
