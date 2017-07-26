require 'rails_helper'

describe UserPhoneForm do
  let(:user) { build_stubbed(:user, :signed_up) }
  let(:params) do
    {
      phone: '555-555-5000',
      international_code: 'US',
      otp_delivery_preference: 'sms',
    }
  end
  subject { UserPhoneForm.new(user) }

  it_behaves_like 'a phone form'

  it 'loads initial values from the user object' do
    user = build_stubbed(
      :user,
      phone: '+1 (555) 500-5000',
      otp_delivery_preference: 'voice'
    )
    subject = UserPhoneForm.new(user)

    expect(subject.phone).to eq(user.phone)
    expect(subject.international_code).to eq('US')
    expect(subject.otp_delivery_preference).to eq(user.otp_delivery_preference)
  end

  it 'infers the international code from the user phone number' do
    user = build_stubbed(:user, phone: '+81 744 21 1234')
    subject = UserPhoneForm.new(user)

    expect(subject.international_code).to eq('JP')
  end

  describe '#submit' do
    it 'does not update the user phone attribute'

    it 'updates to user otp delivery preference if the phone is unset'

    context 'when otp_delivery_preference is voice and phone number does not support voice' do
      it 'is invalid'
    end
  end

  describe '#phone_changed?' do
    it 'returns true if the user phone has changed' do
      params[:phone] = '+1 504 444 1643'
      subject.submit(params)

      expect(subject.phone_changed?).to eq(true)
    end

    it 'returns false if the user phone has not changed' do
      params[:phone] = user.phone
      subject.submit(params)

      expect(subject.phone_changed?).to eq(false)
    end
  end
end
