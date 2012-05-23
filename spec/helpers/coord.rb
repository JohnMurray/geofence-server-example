module Coord
  def lats(coords)
    coords.map {|c| c.last }
  end

  def lons(coords)
    coords.map {|c| c.first }
  end

  def max_lon(coords)
    lons(coords).max
  end

  def max_lat(coords)
    lats(coords).max
  end

  def min_lon(coords)
    lons(coords).min
  end

  def min_lat(coords)
    lats(coords).min
  end
end
