# typed: false

class WebhookPayload < T::Struct
  include ActsAsComparable

  const :event_id, String, name: "eventId"
  const :email_address, String, name: "emailAddress"
  const :retries, Integer, default: 0
end
