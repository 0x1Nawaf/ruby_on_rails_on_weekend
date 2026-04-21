require "test_helper"
class BlobsControllerTest < ActionDispatch::IntegrationTest
  test "auth token is valid" do
    user = users(:one)
    user_token = user.user_tokens.create!
    post api_v1_blobs_path, headers: { HTTP_AUTHORIZATION: "Token token=#{user_token.token}" }
    assert_response :success
    assert_includes response.body, "failed"
  end

  test "auth token is not valid" do
    user = users(:one)
    user_token = user.user_tokens.create!
    user_token.update!(activated: false)
    post api_v1_blobs_path, headers: { HTTP_AUTHORIZATION: "Token token=#{user_token.token}" }
    assert_response :unauthorized
    assert_includes response.body, "unauthenticated"
  end



  #-------- success storing test -------------
  test "stroing and retrieving" do
    user = users(:one)
    user_token = user.user_tokens.create!

    file = File.open("storage/test.jpg", "rb")
    file_data = Base64.encode64(file.read)

    post api_v1_blobs_path, headers: { HTTP_AUTHORIZATION: "Token token=#{user_token.token}" }, params: {storing_type: "s3", data: file_data}, as: :json


    
    json = JSON.parse(response.body)

    assert_response :success
    assert_includes response.body, "success"

    stored_ref_id = json["id"]

    #---retrieving---
    get "#{api_v1_blobs_path}/#{stored_ref_id}", headers: { HTTP_AUTHORIZATION: "Token token=#{user_token.token}" }
    assert_response :success
    assert_includes response.body, "id"

  end
  #-------- success storing test -------------





  #-------- unsuccessful storing test  if data key not exist-------------
  test "unsuccessful stroing" do
    user = users(:one)
    user_token = user.user_tokens.create!
    post api_v1_blobs_path, headers: { HTTP_AUTHORIZATION: "Token token=#{user_token.token}" }, params: {storing_type: "local"}, as: :json

    assert_response :success
    assert_includes response.body, "failed"
  end
  #-------- unsuccessful storing test  if data key not exist-------------
end