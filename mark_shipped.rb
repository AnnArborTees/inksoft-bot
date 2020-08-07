require 'rubygems'
require 'bundler'

Bundler.setup
require 'byebug'
require 'watir'
require './lib/support'
require './lib/inksoft'
require './lib/softwear_inksoft'
require 'mysql2'


orders = SoftwearInksoft::inksoft_orders_to_update(@client)
inksoft = Inksoft.new(credentials: @inksoft_credentials)
inksoft.login

orders.each do |order|
  inksoft.goto_order(order['inksoft_id'])
  next if inksoft.order_completed?
  if order['shipment_type'].include?('Cheapest Method to Koppert Biological Systems')
    inksoft.mark_ready_to_pickup
    inksoft.record_pickup_with_tracking(order['tracking_number'], "Shipped to Koppert")
  else
    inksoft.mark_ready_to_ship
    inksoft.record_shipment(order['tracking_number'])
  end
end

inksoft.close

