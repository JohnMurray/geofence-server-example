

module Geofence

    # Given an array of coordinat pairs, create a fence estimation and then
    # store that fence within Mongo. Return the Mongo-document that will be
    # stored (containing the estimated ponts and the document id)
    def self.create_fence(coords)
    end

    # Given the id (document id) of a particular fence and a position (lat,
    # lon), return the poition relative to the fence. This includes two vaules:
    # inside-fence  and  outside-fence
    def self.relative_to_fence(id, pos)
    end

end
