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
      # TODO store fence in Mongo
      # TODO ensure the index is applied
    end

    # Coord is of format:
    # {
    #   lon: x,
    #   lat: y
    # }
    def within_fence?(coord)
      # TODO search for fence in Mongo given coordinate
    end

  end
end
