require 'spec_helper'

describe Accounting::AreaManagerRegionsController do
  extend AccessControlHelpers
  should_be_list_authorized_for_only 'sales'
  should_be_create_authorized_for_only 'sales'
  should_be_delete_authorized_for_only 'sales'
end
