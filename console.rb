#!/usr/bin/env ruby

# require all the necessary files
require 'pry'
$: << ::File.expand_path('../src', __FILE__)
require 'app'
require 'geofence'

# specify some sample fences to play with
# 
# format:
#   [
#     [:lon, :lat],
#     ...
#   ]
fence_1 = [
  [0, 0],
  [3, 0],
  [4, 2],
  [6, 3],
  [6, 6],
  [5, 7],
  [3, 5],
  [2, 4],
  [0, 1]
]

fence_2 = [
  [5, 5],
  [7, 5],
  [3, 2],
  [10, 2],
  [12, 7],
  [12, 10],
  [15, 10],
  [15, 15],
  [12, 15],
  [10, 18],
  [8, 15],
  [7, 15],
  [6, 13],
  [5, 10]
]

# patch pretty-print to use a smaller width for looking at our fences
class PP
  class << self
    alias_method :old_pp, :pp
    def pp(obj, out = $>, width = 40)
      old_pp(obj, out, width)
    end
  end
end


# include helpers to play around with Sinatra application
include Rack::Test::Methods
self.instance_eval do
  @app = App.new
  def app; @app; end
end


# start the console! :-)
system('clear')
puts <<eos
This is my interactive playground. You can call the Sinatra methods in
the same way you would in RSpec (get, post). There are also a couple of
test fences defined for you (fence_1, fence_2). I also monkey-patched
'pp' to print short arrays nicer.

Everything you would want to play with (for this project) should be in here

eos
Pry.start


