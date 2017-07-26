class UserPhoneForm
  include ActiveModel::Model
  include FormPhoneValidator
  include OtpDeliveryPreferenceValidator

  attr_accessor :phone, :international_code, :otp_delivery_preference

  def initialize(user)
    self.user = user
    self.phone = user.phone
    self.international_code = Phonelib.parse(phone).country || PhoneFormatter::DEFAULT_COUNTRY
    self.otp_delivery_preference = user.otp_delivery_preference
  end

  def submit(params)
    self.international_code = params[:international_code]
    self.phone = PhoneFormatter.new.format(
      params[:phone],
      country_code: international_code
    )
    self.otp_delivery_preference = params[:otp_delivery_preference]

    update_otp_delivery_preference_for_user if otp_delivery_preference_changed?

    FormResponse.new(success: valid?, errors: errors.messages, extra: extra_analytics_attributes)
  end

  def phone_changed?
    user.phone != phone
  end

  private

  attr_accessor :user

  def extra_analytics_attributes
    {
      otp_delivery_preference: otp_delivery_preference,
    }
  end

  def otp_delivery_preference_changed?
    otp_delivery_preference != user.otp_delivery_preference
  end

  def update_otp_delivery_preference_for_user
    user_attributes = { otp_delivery_preference: otp_delivery_preference }
    UpdateUser.new(user: user, attributes: user_attributes).call
  end
end
