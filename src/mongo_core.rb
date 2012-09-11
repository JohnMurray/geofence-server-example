# A simple class for interacting w/ Mongo
module MongoCore
  class << self 
    
    # The search radius to use when querying the
    # Mongo. 
    SEARCH_RADIUS = (0.25 ** 2 * 2) ** 0.5
    
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
    def within_fence?(coords, mongo_id)
      # search for fence in Mongo given coordinate
      radius = 0.5199   # same as sqrt(0.5 ** 2) + 0.01
      @coll.find({
        coordinates: {
          :$near         => coords, # [lon, lat]
          :$maxDistance  => radius
        },
        _id: mongo_id
      }).count > 1
    end


    # Return all of the fences straight from mongo
    def get_all_fences
      @coll.find.to_a
    end

  end
end
