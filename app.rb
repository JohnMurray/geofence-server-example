require 'bundler/setup'
Bundler.require(ENV['ENV'].nil? ? :development : ENV['ENV'].to_sym)
require 'json'


class App < Sinatra::Base

  get '/' do
    # return some documentaiton or a link to the tutorial/github page
    # where they can find some documentaiton.
  end

  post '/create-fence' do
    # 1. take a JSON body of coordinate-pairs
    # 2. create and store a fence in Mongo
    # 3. return array of grid-block center-points and the fence id
  end

  get '/relative-to-fence/:id/:lat/:lon' do
    # given the fence id and position, return either:
    # 'inside fence'  or  'outside_fence'
  end

end
