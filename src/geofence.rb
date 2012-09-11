module Geofence

    MAX_COORD = 180

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
    #   a. generate the sub-grid (for the horizontal section)
    #   b. get the intersecting lines
    #   c. for each instersecting line
    #     i. for each grid-block within the horizontal sub-section
    #        1. add the grid-block if the block is to the left of
    #           the intersecting line 
    #        2. else, remove the grid-block from the collection of
    #           included blocks.
    def self.create_fence(coords)


      # get the bounding-box for the polygon (1)
      bounds = get_bounding_box(coords)

      # get the horizontals from the polygon (2)
      horizontals = get_horizontals(coords)

      # split coordinates up into lines (makes life easier)
      lines = coords.zip(coords.dup.rotate(-1))
      lines.map! {|l| l.sort! {|a,b| a.last <=> b.last } }

      # compute the grid (3)
      grid = generate_grid(bounds)
      estimated_fence = Set.new([])
      horizontals.each do |horizontal|
        # generate the sub-grid (3-a)
        sub_grid = grid.select do |g|
          g.last.between?(horizontal.first, horizontal.last)
        end
        # get the intersecting lines (3-b)
        # and iterate through them (3-b)
        intersecting_lines(horizontal, lines).each do |line|
          # iterate throught the horizontal sub-sections (3-b-i)
          sub_grid.each do |point|
            if det(line, point) > 0
              # remove existing point from estimate (3-b-i-1)
              if estimated_fence.include?(point)
                estimated_fence.delete(point)
              # add point to estimate (3-b-i-2)
              else
                estimated_fence << point
              end
            end
          end
        end
      end

      estimated_fence
    end


    private
    def self.get_bounding_box(coords)
      # get max and min coords
      max = coords.inject({lat:0, lon:0}) do |max, c|
        max[:lon] = c[0] if c[0] > max[:lon]
        max[:lat] = c[1] if c[1] > max[:lat]
        max
      end
      min = coords.inject({lat:MAX_COORD, lon:MAX_COORD}) do |min, c|
        min[:lon] = c[0] if c[0] < min[:lon]
        min[:lat] = c[1] if c[1] < min[:lat]
        min
      end
      # add a little padding to the max and min
      max.each {|k, v| max[k] += 1 }
      min.each {|k, v| min[k] -= 1 }

      {min: min, max: max}
    end


    # The lines represent lines on the polygons. For example, a triangle
    # of points: [a, b, c] would have lines of:
    #   (a,b) (b,c) (c,a)
    # 
    # Lines in format of:
    # [
    #   [<coordN>, <coord1>],
    #   [<coord1>, <coord2>],
    #   ..., 
    #   [<coordN-1>, <coordN>]
    # ]
    def self.get_horizontals(coords)
      #get all individual horizontals
      h1 = coords.inject([]) do |arr, (lon, lat)|
        arr << lat unless arr.include? lat
        arr
      end

      #wrap those individuals up into cyclic pairs
      h1.sort!
      h2 = h1.dup
      h1.pop
      h2.shift
      h1.zip(h2)
    end


    # We need to create a conceptual grid in which to do our estimation
    # against. We're actually going to represent our grid-blocks by their
    # centerpoint. Ex:
    # 
    #  _______
    # |       |
    # |   +   |  -- Box and center-point
    # |_______|
    # 
    # We're representing our blocks as points because that's how we're
    # going store and index our fence in Mongo when it's all said and
    # done.
    # 
    # Note: In real-life, we might want to adjust the size of the grid-block
    #       based on how large the geofence is, how granular your estimation
    #       will be, etc. For this example, we're going to use a fixed size
    #       grid block of 0.5x0.5
    def self.generate_grid(bounds)
      lon_range = bounds[:min][:lon]...bounds[:max][:lon]
      lat_range = bounds[:min][:lat]...bounds[:max][:lat]

      grid = []
      lon_range.each do |lon|
        lat_range.each do |lat|
          grid << [lon + 0.25, lat + 0.25]
          grid << [lon + 0.25, lat + 0.75]
          grid << [lon + 0.75, lat + 0.25]
          grid << [lon + 0.75, lat + 0.75]
        end
      end

      grid
    end


    # Given a horizonal (two lat points) and the set of lines that constitute
    # our polygon, determine what lines intersect the space created by the
    # horizontal (or horizontal sub-section if you prefer to think of it that
    # way)
    # 
    # 
    # ---*------------------------------------------------
    #     \
    #      \  - intersecting line           [horizontal section]
    #       \
    # -------*--------------------------------------------
    #        |
    #        |
    #        |
    #        ...
    # 
    # 
    # h  = horizontal
    # ls = lines
    def self.intersecting_lines(h, ls)
      ls.select do |l|
        l.first.last <= h.first && l.last.last >= h.last
      end
    end

   
    # Get the determinant of a line and a point. This is conceptually
    # represented by the following:
    # 
    # point = (a,b)
    # line  = [(x1, y1), (x2, y2)], such that y2 > y1
    # 
    # matrix:
    # | (x2 - x1)    (a-x1) |
    # | (y2 - y1)    (b-y1) |
    # 
    # determinent: 
    #   (x2 - x1)*(b-y1)  -  (y2-y1)*(a-x1)
    # 
    # 
    # Assertions:
    #   determinent > 0  <->  point lies to left of line
    #   determinent = 0  <->  point lies on the line
    #   determinent < 0  <->  pont lies to right of line
    #
    # Line:  [[x1,y1],[x2,y2]]
    # Point: [a,b]
    def self.det(line, point)
      x1 = line.first.first
      y1 = line.first.last

      x2 = line.last.first
      y2 = line.last.last

      a = point.first
      b = point.last

      (x2 - x1)*(b-y1)  -  (y2-y1)*(a-x1)
    end

end
