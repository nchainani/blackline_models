class Stop
  attr_accessor :id, :lat, :lng, :name, :direction, :time
  attr_accessor :route_run

  def self.initWithHttpStop(route_run, stop)
    obj = new
    obj.id = stop['id']
    obj.lat = stop['lat']
    obj.lng = stop['lng']
    obj.name = stop['name']
    obj.direction = stop['direction']
    obj.time = stop['time']

    obj.route_run = route_run
    obj
  end

end