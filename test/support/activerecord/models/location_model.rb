# typed: true
# frozen_string_literal: true

class LocationModel < ActiveRecord::Base
  self.table_name = "locations"

  has_many :user_models, foreign_key: "location_id"
  belongs_to :country, class_name: "CountryModel", foreign_key: "country_id", optional: true
end
