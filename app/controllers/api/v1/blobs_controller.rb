class Api::V1::BlobsController < Api::V1::AuthenticationController
    
    def store
        storing_res = helpers.store_object(user, request)

        if storing_res == nil
            render json: {message: "failed! to store the object"}
            return 
        end

        storing_res["message"] = "success, file has been saved"
        render json: storing_res
    end

    def retrieve

        response = helpers.retrieve_object(user, request.params[:id])
        if response == nil
            render json: {message: "failed! to retrieve the object"}
            return
        end
        
        render json: response
    end       
end