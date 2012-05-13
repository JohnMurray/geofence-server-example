module Geofence

    # Given an array of coordinat pairs, create a fence estimation and then
    # store that fence within Mongo. Return the Mongo-document that will be
    # stored (containing the estimated ponts and the document id)
    #--
    # Coordinates in format of:
    # [
    #   [:lon, :lat],
    #   [:lon, :lat],
    #   ...
    # ]
    # 
    # ALGORITHM
    # 1. Get the bounding box and generate grid within box
    # 2. Generate the horizontals
    # 3. Foreach horizontal secion of the grid
    #   a. get the intersecting lines
    #   b. for each instersecting line
    #     i. for each grid-block within the horizontal sub-section
    #        1. add the grid-block if the block is to the left of
    #           the intersecting line 
    #        2. else, remove the grid-block from the collection of
    #           included blocks.
    def self.create_fence(coords)


      # get the bounding-box for the polygon (1)
      bounds = coords.inject({lat:0, lon:0}) do |max, c|
        max[:lon] = c[0] if c[0] > max[:lon]
        max[:lat] = c[1] if c[1] > max[:lat]
        max
      end

      # generate the grid within the bounding-box
      # TODO generate teh grid

      # get the horizontals from the polygon (2)
      # TODO make this sexier (ugh...)
      h1 = coords.inject([]) do |arr, (lon, lat)|
        arr << lat unless arr.include? lat
        arr
      end
      h2 = h1.dup
      h1.pop
      h2.shift
      horizontals = h1.zip(h2)

      # split coordinates up into lines (makes life easier)
      # Lines in format of:
      # [
      #   [<coordN>, <coord1>],
      #   [<coord1>, <coord2>],
      #   ...,
      #   [<coordN-1>, <coordN>]
      # ]
      lines = coords.zip(coords.dup.rotate(-1))

      # compute the grid (3)
      # TODO rewrite for new horizontal structure
      horizontals.each_with_index do |h, i|
        max_h, min_h = h > horizontals[i+1]
        # get the intersecting lines (3-a)
        i_lines = lines.map do |l|
          
        end
      end
      
    end


    # Given the id (document id) of a particular fence and a position (lat,
    # lon), return the poition relative to the fence. This includes two vaules:
    # inside-fence  and  outside-fence
    def self.relative_to_fence(id, pos)
    end

end
