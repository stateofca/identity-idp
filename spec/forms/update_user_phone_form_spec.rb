require 'rails_helper'

describe UpdateUserPhoneForm do
  let(:user) { build_stubbed(:user, :signed_up) }
  let(:params) { { phone: '555-555-5000', international_code: 'US' } }

  subject { UpdateUserPhoneForm.new(user) }

  it_behaves_like 'a phone form'
end
