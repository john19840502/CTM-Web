require 'spec_helper'

describe Compliance::Rego::RegoReportsController do
  extend AccessControlHelpers

  should_be_list_authorized_for_only 'risk_management', 'compliance'
end
