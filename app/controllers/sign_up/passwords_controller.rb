module SignUp
  class PasswordsController < ApplicationController
    include UnconfirmedUserConcern

    def new
      with_unconfirmed_user
    end

    def create
      with_unconfirmed_user do
        result = @password_form.submit(permitted_params)
        analytics.track_event(Analytics::PASSWORD_CREATION, result.to_h)
        store_sp_metadata_in_session unless sp_request_id.empty?

        if result.success?
          process_successful_password_creation
        else
          process_unsuccessful_password_creation
        end
      end
    end

    private

    def permitted_params
      params.require(:password_form).permit(:confirmation_token, :password, :request_id)
    end

    def process_successful_password_creation
      @user.confirm
      UpdateUser.new(
        user: @user,
        attributes: { reset_requested_at: nil, password: permitted_params[:password] }
      ).call
      sign_in_and_redirect_user
    end

    def store_sp_metadata_in_session
      StoreSpMetadataInSession.new(session: session, request_id: sp_request_id).call
    end

    def sp_request_id
      permitted_params.fetch(:request_id, '')
    end

    def process_unsuccessful_password_creation
      @confirmation_token = params[:confirmation_token]
      render :new, locals: { request_id: sp_request_id }
    end

    def sign_in_and_redirect_user
      sign_in @user
      redirect_to after_confirmation_path_for(@user)
    end
  end
end
