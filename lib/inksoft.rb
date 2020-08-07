class Inksoft
  attr_accessor :credentials

  def initialize(args)
    if args[:credentials]
      @credentials = args[:credentials]
    end
  end

  def browser
    @browser ||= initialize_browser
  end

  def login
    browser.goto("#{credentials[:url]}/ordermanager/")
    browser.text_field(id: 'username').set credentials[:username]
    browser.text_field(id: 'password').set credentials[:password]
    browser.button(value: 'Sign In').click
  end

  def initialize_browser
     Watir::Browser.new
  end

  def goto_order(id)
    puts "goto_order(#{id}) START"
    browser.goto("#{credentials[:url]}/ordermanager/order/#{id}")
    browser.wait_until(timeout: 10, message: 'Visiting the order page timed out') do |b|
      b.a(id: "orderId").text == id.to_s
    end
    puts "goto_order(#{id}) DONE"
  end

  def order_completed?
    completed = (
      browser.div(class: 'tag-completed').present? ||
      browser.div(class: 'tag-canceled').present?
    )
    puts "order_completed? returned #{completed}"
    completed
  end

  def mark_ready_to_ship
    puts "mark_ready_to_ship START"

    return if browser.div(class: 'tag-readytoship').present?
    browser.element(id: 'matMenuAction').click
    browser.wait_until{|b| b.span(text: 'Mark Ready To Ship').present? }
    browser.span(text: 'Mark Ready To Ship').click
    browser.element(tag_name: 'warning-modal').button(id: 'successBtn').click

    puts "mark_ready_to_ship DONE"
  end


  def mark_ready_to_pickup
    puts "mark_ready_to_pickup START"

    return if browser.div(class: 'tag-readyforpickup').present?
    browser.element(id: 'matMenuAction').click
    browser.wait_until{|b| b.span(text: 'Mark Ready To Ship').present? }
    browser.span(text: 'Mark Ready To Pickup').click
    browser.element(tag_name: 'warning-modal').button(id: 'successBtn').click

    puts "mark_ready_to_pickup DONE"
  end

  def record_pickup_with_tracking(tracking, message)
    begin
      puts "record_pickup_with_tracking(#{tracking}) START"
      browser.wait_until{|b| b.div(class: 'tag-readyforpickup').present? }
      sleep 5

      browser.span(text: 'Record Pickup').click
      browser.text_field(id: 'recipName').set message
      browser.textarea(id: 'comment').set "Tracking: #{tracking}"

      browser.button(id: 'defaultPositiveSuccessBtn').click

      puts "record_pickup_with_tracking(#{tracking}) END"
    rescue Exception => e
      byebug
    end
  end

  def record_shipment(tracking)
    begin
      puts "record_shipment(#{tracking}) START"
      browser.wait_until{|b| b.div(class: 'tag-readytoship').present? }
      sleep 5

      browser.span(text: 'RECORD SHIPMENT').click
      browser.text_field(id: 'trackingNumber').set tracking
      until(!browser.element(tag_name: 'record-shipment-modal').checkbox(label: /Notify customer/).set?)
        browser.span(text: /Notify customer/).click
      end
      browser.button(id: 'defaultPositiveSuccessBtn').click

      puts "record_shipment(#{tracking}) END"
    rescue Exception => e
      byebug
    end
  end

  def close
    @browser.close
  end

end
