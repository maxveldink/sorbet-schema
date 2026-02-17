# typed: true
# frozen_string_literal: true

class UserModel < ActiveRecord::Base
  self.table_name = "users"

  belongs_to :location, class_name: "LocationModel", foreign_key: "location_id"
end
