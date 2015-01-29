class RouteRun
  attr_accessor :id, :remaining_tickets, :run_datetime, :run_date_pretty, :run_datetime_pretty, :amount, :currency
  attr_accessor :status, :lat, :lng
  attr_accessor :stops
  attr_accessor :route
  attr_accessor :tickets

  def self.initWithHttpRouteRun(route, run)
    obj = new
    obj.prepareObject(run)
    obj.stops = {}

    run['details'].each do |stop|
      obj.stops[stop['id']] = Stop.initWithHttpStop(obj, stop)
    end

    obj.route = route
    obj
  end

  def start(&block)
    HttpClient.post("#{ROUTES_PATH}/#{route.id}/route_runs/#{self.id}/start") do |response|
      if response.ok?
        prepareStatus(response.body)
        block.call(response.body, nil)
      else
        block.call(nil, response.errorString)
      end
    end
  end

  def complete(&block)
    HttpClient.post("#{ROUTES_PATH}/#{route.id}/route_runs/#{self.id}/complete") do |response|
      if response.ok?
        prepareStatus(response.body)
        block.call(response.body, nil)
      else
        block.call(nil, response.errorString)
      end
    end
  end

  def updateLocation(lat, lng)
    HttpClient.post("#{ROUTES_PATH}/#{route.id}/route_runs/#{self.id}/updateLocation", lat: lat, lng: lng) do |response|
      p "location udpated #{response.ok?}"
      if response.ok?
        prepareStatus(response.body)
      end
    end
  end

  def get_tickets(&block)
    HttpClient.get("#{ROUTES_PATH}/#{route.id}/route_runs/#{self.id}/tickets") do |response|
      if response.ok?
        self.tickets = response.body.map { |ticket_data| Ticket.initFromHttpTicket(ticket_data) }
        block.call(self.tickets)
      end
    end
  end

  def reload(&block)
    HttpClient.get("#{ROUTES_PATH}/#{route.id}/route_runs/#{self.id}") do |response|
      if response.ok?
        run = response.body
        prepareObject(run)
        block.call
      end
    end
  end

  def prepareObject(run)
    self.id = run['id']
    self.remaining_tickets = run['remaining_tickets']
    self.run_datetime = run['run_datetime']
    self.run_date_pretty = run['run_date_pretty']
    self.run_datetime_pretty = run['run_datetime_pretty']
    self.amount = run['amount']
    self.currency = run['currency']
    prepareStatus(run)
  end

  def prepareStatus(run)
    self.status = run['status']
    self.lat = run['lat']
    self.lng = run['lng']
  end
end