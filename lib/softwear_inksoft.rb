module SoftwearInksoft
  def self.inksoft_orders_to_update(client)
    query =
"select
*
from orders
where process_with = 'softwear-retail'
and softwear_status = 'complete'
and tracking_number is not null
and shipment_type is not null
and tracking_number != ''
and inksoft_status != 'complete'"
    results = client.query(query)
  end

end
