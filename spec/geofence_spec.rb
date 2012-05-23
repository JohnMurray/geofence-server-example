require 'spec_helper'

describe Geofence do
  
  before(:all) do
    @coords_1 = [
      [1, 1],
      [5, 1],
      [3, 3],
      [5, 5],
      [1, 5]
    ]
    @coords_2 = [
      [2, 3],
      [1, 5],
      [5, 5],
      [3, 3],
      [5, 1],
      [1, 1]
    ]
    @coords_3 = [
      [5, 5],
      [7, 3],
      [9, 2],
      [9, 4],
      [10, 7],
      [12, 6],
      [12, 10],
      [20, 15],
      [12, 13],
      [10, 9],
      [8, 9],
      [7, 11],
      [6, 11]
    ]

    @fences = [@coords_1, @coords_2, @coords_3]

    @coord_helper = Class.new { include Coord }.new
  end

  describe '#get_bounding_box' do
    
    it 'should return the (max-coordinates + 1) for a polygon' do
      @fences.each do |coords|
        box = Geofence.send(:get_bounding_box, coords)[:max]
        box[:lon].should eq(@coord_helper.max_lon(coords) + 1)
        box[:lat].should eq(@coord_helper.max_lat(coords) + 1)
      end
    end

    it 'should return the (min-coordinates - 1) for a polygon' do
      @fences.each do |coords|
        box = Geofence.send(:get_bounding_box, coords)[:min]
        box[:lon].should eq(@coord_helper.min_lon(coords) - 1)
        box[:lat].should eq(@coord_helper.min_lat(coords) - 1)
      end
    end

  end

  describe '#get_horizontals' do

    it 'should return a horizontal for each lat point' do
      @fences.each do |fence|
        horizontals = Geofence.send(:get_horizontals, fence)
        horizontals.flatten!
        fence.each do |coord|
          horizontals.should include(coord.last)
        end
      end
    end

    it 'should return contiguous sections' do
      @fences.each do |fence|
        horizontals = Geofence.send(:get_horizontals, fence)
        prev = nil
        horizontals.each do |h|
          h.first.should eq(prev) if prev
          prev = h.last
        end
      end
    end
  end

  describe '#generate_grid' do
    it 'should generate 4 blocks for a 1x1 bounds' do
      bounds = {
        max: {lon: 1, lat: 1},
        min: {lon: 0, lat: 0}
      }
      grid = Geofence.send(:generate_grid, bounds)
      grid.size.should eq(4)
    end

    it 'should represent each 1x1 block with 4 equal-size blocks' do
      bounds = {
        max: {lon: 1, lat: 1},
        min: {lon: 0, lat: 0}
      }
      grid = Geofence.send(:generate_grid, bounds)
      grid.should include([0.25, 0.25])
      grid.should include([0.25, 0.75])
      grid.should include([0.75, 0.25])
      grid.should include([0.75, 0.75])
    end
  end

end
