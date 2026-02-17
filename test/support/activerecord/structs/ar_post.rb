# typed: strict
# frozen_string_literal: true

require_relative "ar_post_status"

class ARPost < T::Struct
  include ActsAsComparable

  const :title, String
  const :status, ARPostStatus
end
