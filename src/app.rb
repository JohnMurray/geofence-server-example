require 'bundler/setup'
Bundler.require(ENV['ENV'].nil? ? :development : ENV['ENV'].to_sym)
require 'json'

$: << ::File.expand_path('../', __FILE__)
require 'mongo_core'
require 'geofence'


class App < Sinatra::Base

  configure do
    mime_type :json, 'application/json'
    set :port, 4242
  end

  before do
    content_type :json
    MongoCore.init
  end

  
  get '/fences' do
    MongoCore.get_all_fences.to_json
  end


  post '/fences' do
    # 1. take a JSON body of coordinate-pairs
    json = request.body.read
    begin
      json = JSON.parse(json)
    rescue JSON::ParseError
      status 500
      return "Incorrectly formatted JSON"
    end
    # 2. create and store a fence in Mongo
    fence = Geofence.create_fence(json)
    MongoCore.store_fence(fence)
    # 3. return array of grid-block center-points and the fence id
    fence.to_json
  end


  get '/relative-to-fence/:id/:lat/:lon' do
    # given the fence id and position, return either:
    # 'inside fence'  or  'outside_fence'
    coords   = [params[:lon], params[:lat]].map{|x| x.to_i}
    mongo_id = BSON::ObjectId.from_string(params[:id])

    in_fence = MongoCore.within_fence?(coords, mongo_id)
    { in_fence: in_fence }.to_json
  end

end
