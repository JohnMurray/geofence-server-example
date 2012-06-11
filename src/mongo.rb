module Mongo
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
    #     { Longitude: x, Latitude: y },
    #     ...
    #   ]
    # }
    def store_fence(fence)
      # TODO test mongo driver
      # TODO convert fence from array to format above
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
