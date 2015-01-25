class Route

  attr_accessor :id, :name, :description
  attr_accessor :direction, :polyline
  attr_accessor :routeRuns, :stops, :origin, :destination
  attr_accessor :_hash

  def self.initWithHttpRoute(route)
    obj = new
    obj.prepareObject(route)
  end

  def reload(&block)
    HttpClient.get("#{ROUTES_PATH}/#{id}") do |response|
      if response.ok?
        route = response.body
        prepareObject(route)
        block.call
      end
    end
  end

  def prepareObject(route)
    self.id   = route['id']
    self.name = route['name']
    self.description = route['description']
    self.direction   = route['direction']
    self.polyline    = route['polyline']

    self.routeRuns = {}
    route['runs'].each do |run|
      self.routeRuns[run['id']] = RouteRun.initWithHttpRouteRun(self, run)
    end

    self.stops = {}
    route['locations'].each do |stop|
      self.stops[stop['id']] = Stop.initWithHttpStop(nil, stop)
    end

    unless self.stops.empty?
      origin = self.stops.values.first
      destination = self.stops.values.last
      self.origin = CLLocationCoordinate2D.new(origin.lat, origin.lng)
      self.destination = CLLocationCoordinate2D.new(destination.lat, destination.lng)
    end

    self._hash = route
    self
  end

  def self.aroundLocation(lat, lng, radius, &block)
    params = {lat: lat, lng: lng, radius: radius}

    HttpClient.get(ROUTES_PATH, params) do |response|
      if response.ok?
        routes = response.body rescue []
        routes_obj = routes.map do |route|
          initWithHttpRoute(route)
        end
        block.call(routes_obj) if block
      end
    end
  end
end