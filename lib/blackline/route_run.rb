class RouteRun
  attr_accessor :id, :remaining_tickets, :run_datetime, :amount, :currency
  attr_accessor :stops
  attr_accessor :route

  def self.initWithHttpRouteRun(route, run)
    obj = new
    obj.id = run['id']
    obj.remaining_tickets = run['remaining_tickets']
    obj.run_datetime = run['run_datetime']
    obj.amount = run['amount']
    obj.currency = run['currency']

    obj.stops = {}

    run['details'].each do |stop|
      obj.stops[stop['id']] = Stop.initWithHttpStop(obj, stop)
    end

    obj.route = route
    obj
  end
end