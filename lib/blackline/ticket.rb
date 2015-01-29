class Ticket
  attr_accessor :id, :uuid, :name, :route_name, :route_time, :stop_name, :stop_time, :amount, :currency, :status

  attr_accessor :rider_id, :route_run_id, :run_date_pretty, :run_datetime_pretty, :qr_code

  def self.initFromHttpTicket(ticket_data)
    obj = new
    obj.id = ticket_data['id']
    obj.uuid = ticket_data['uuid']
    obj.route_name = ticket_data['route_name']
    obj.amount = ticket_data['amount']
    obj.currency = ticket_data['currency']
    obj.status = ticket_data['status']

    obj.name = ticket_data['rider']['name']
    obj.rider_id = ticket_data['rider']['id']

    if ticket_data['route_run']
      obj.route_time = ticket_data['route_run']['run_datetime']
      obj.run_date_pretty = ticket_data['route_run']['run_date_pretty']
      obj.run_datetime_pretty = ticket_data['route_run']['run_datetime_pretty']
    end

    if ticket_data['location']
      obj.stop_name = ticket_data['location']['name']
      obj.stop_time = ticket_data['location']['time']
    end

    obj
  end

  def image(&block)
    if qr_code
      block.call(qr_code)
    else
      params = { cht: :qr, chs: '200x200', ch1: uuid }.merge(User.currentUser.to_hash)
      HttpClient.getImage("api/v1/tickets/#{id}/smallImage", params) do |response|
        if response.ok?
          @qr_code = response.body
          block.call(@qr_code)
        end
      end
    end
  end

  def boarded(&block)
    HttpClient.post("#{TICKETS_PATH}/#{id}/boarded", {}) do |response|
      if response.ok?
        self.status = 'boarded'
        block.call
      end
    end
  end
end