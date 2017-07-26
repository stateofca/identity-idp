require 'rails_helper'

describe TwoFactorSetupForm, type: :model do
  let(:user) { build_stubbed(:user) }
  let(:phone) { '+1 (202) 202-2020' }
  let(:international_code) { 'US' }
  let(:params) do
    {
      phone: phone,
      international_code: 'US',
      otp_delivery_preference: 'sms',
    }
  end
  subject { TwoFactorSetupForm.new(user) }

  it_behaves_like 'a phone form'
  it_behaves_like 'an otp delivery preference form'

  describe 'phone uniqueness' do
    context 'when phone is empty' do
      let(:phone) { '' }

      it 'does not add already taken errors' do
        errors = {
          phone: [t('errors.messages.improbable_phone')],
        }
        extra = {
          otp_delivery_preference: 'sms',
        }
        result = instance_double(FormResponse)

        expect(FormResponse).to receive(:new).
          with(success: false, errors: errors, extra: extra).and_return(result)
        expect(subject.submit(params)).to eq result
      end
    end
  end

  describe '#submit' do
    context 'when otp_delivery_preference is the same as the user otp_delivery_preference' do
      it 'does not update the user' do
        user = build_stubbed(:user, otp_delivery_preference: 'sms')
        form = TwoFactorSetupForm.new(user)

        expect(UpdateUser).to_not receive(:new)

        form.submit(params)
      end
    end

    context 'when otp_delivery_preference is different from the user otp_delivery_preference' do
      it 'updates the user' do
        user = build_stubbed(:user, otp_delivery_preference: 'voice')
        form = TwoFactorSetupForm.new(user)
        attributes = { otp_delivery_preference: 'sms' }

        updated_user = instance_double(UpdateUser)
        allow(UpdateUser).to receive(:new).
          with(user: user, attributes: attributes).and_return(updated_user)

        expect(updated_user).to receive(:call)

        form.submit(params)
      end
    end
  end
end
