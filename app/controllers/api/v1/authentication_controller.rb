class Api::V1::AuthenticationController < ActionController::Base
    before_action :authenticate
    protect_from_forgery with: :null_session

    attr_reader :user

    def authenticate
        authenticate_user_with_token || handle_unauthenticate
    end


    private

        def authenticate_user_with_token
            authenticate_with_http_token do |token, options|
                user_token = UserToken.where(activated: true).find_by(token: token)

                @user = user_token&.user
            end
        end

        def handle_unauthenticate
            render json: {message: "unauthenticated"}, status: 401
        end
end