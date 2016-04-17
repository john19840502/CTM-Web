require 'spec_helper'

describe Compliance::Rego::CtmExecsController do
  extend AccessControlHelpers

  should_be_list_authorized_for_only 'risk_management', 'compliance'
  should_be_create_authorized_for_only 'compliance'
  should_be_update_authorized_for_only 'compliance'
  should_be_delete_authorized_for_only 'compliance'
end
