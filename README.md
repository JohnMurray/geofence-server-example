# Geofence Server in Ruby (a simple example)

This is a simple example project to showcase geofencing with Ruby and Mongo.
There is a full write-up that can be found on [my blog][1]. 

I make no promises about this server. To be honest it probably has lots of
issues, could be done better, and definitely won't scale. But it's fun to
look at and should give you some ideas when it comes to your own 
implementation.


## Getting Started
Pull from github
```bash
git clone git://github.com/JohnMurray/geofence-server-example.git
```

Install Gems
```bash
cd geofence-server-example
bundle
```

Start Server
```bash
bundle exec thin -p 4242 start
```

Make requests!
```bash
# Create a fence
curl -d '[[0, 0], [0, 4], [4, 0], [4, 4]]' http://127.0.0.1:4242/fences

# Check that it was created 
curl http://127.0.0.1:4242/fences

# Query the fence
# Replace :id with the actual string-representation of a Mongo Document ID
# (You can find that by getting the fences with /fences)
curl http://127.0.0.1:4242/relative-to-fence/:id/lon/lat
```

## Exploring with the Console
Once you've played around with the project's web server, you might want to take
a look at the code. It's rather simple and could serve as a good starting point
for you. If you really want to get hands one with the application you can start
up the interactive console:

```bash
./console.rb
```



  [1]: http://johnmurray.io/log/2012/07/11/Geofencing--Part-1.md
