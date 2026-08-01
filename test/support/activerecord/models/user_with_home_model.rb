# typed: true
# frozen_string_literal: true

class UserWithHomeModel < ActiveRecord::Base
  self.table_name = "users"

  belongs_to :home, class_name: "LocationModel", foreign_key: "location_id", optional: true
end
