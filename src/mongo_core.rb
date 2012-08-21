# A simple class for interacting w/ Mongo
module MongoCore
  class << self 
    
    def init
      @conn = Mongo::Connection.new
      @db   = @conn['sample-geofence']
      @coll = @db['fences']
    end

    # Fence Document in Mongo looks like:
    # {
    #   _id: ObjectId(),
    #   coordinates: [
    #     { lon: x, lat: y },
    #     ...
    #   ]
    # }
    def store_fence(fence)
      # TODO test mongo driver
      # convert fence from array to format above
      mongo_fence = []
      fence.each do |coord|
        mongo_fence << {
          lon: coord[0],
          lat: coord[1]
        }
      end
      # store fence in Mongo
      @coll.insert( { coordinates: mongo_fence } )
      # ensure the index is applied
      @coll.ensure_index([[:coordinates, Mongo::GEO2D]])
    end

    # Coord is of format:
    # {
    #   lon: x,
    #   lat: y
    # }
    def within_fence?(coord)
      # search for fence in Mongo given coordinate
      radius = 0.26    # same as 0.5 ** 2 + 0.01
      @coll.find({
        coordinates: {
          :$near         => [coord[:lon], coord[:lat]],
          :$maxDistance  => radius
        }
      }).count > 1
    end

  end
end
