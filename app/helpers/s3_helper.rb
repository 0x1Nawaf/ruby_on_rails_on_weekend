module S3Helper

    def s3_session_start(path, method="GET")
        #const data
        aws_access_key = Rails.configuration.x.s3.access_key
        aws_secret_key = Rails.configuration.x.s3.secret_key
        bucket_name = Rails.configuration.x.s3.bucket
        region = Rails.configuration.x.s3.region
        #const data

        object_key = path
        method = method
        service = "s3"
        endpoint = "https://#{bucket_name}.s3.#{region}.amazonaws.com/#{object_key}"

        #Time
        current_time = Time.now.utc
        amz_date = current_time.strftime("%Y%m%dT%H%M%SZ")
        date_stamp = current_time.strftime("%Y%m%d")


        #canonicals data
        canonical_uri = "/#{object_key}"
        canonical_headers = "host:#{bucket_name}.s3.#{region}.amazonaws.com\nx-amz-content-sha256:UNSIGNED-PAYLOAD\nx-amz-date:#{amz_date}\n"
        signed_headers = "host;x-amz-content-sha256;x-amz-date"
        payload_hash = "UNSIGNED-PAYLOAD"
        canonical_request = [
            method, canonical_uri, '', canonical_headers, signed_headers, payload_hash
        ].join("\n")
        
        #algorithm stage
        algorithm = "AWS4-HMAC-SHA256"
        credential_scope = "#{date_stamp}/#{region}/#{service}/aws4_request"

        #signing stage
        string_to_sign = [
            algorithm, amz_date, credential_scope, Digest::SHA256.hexdigest(canonical_request)
            ].join("\n")

        date_key = OpenSSL::HMAC.digest("sha256", "AWS4#{aws_secret_key}", date_stamp)
        region_key = OpenSSL::HMAC.digest("sha256", date_key, region)
        service_key = OpenSSL::HMAC.digest("sha256", region_key, service)
        signing_key = OpenSSL::HMAC.digest("sha256", service_key, "aws4_request")
        signature = OpenSSL::HMAC.hexdigest("sha256", signing_key, string_to_sign)

        authorization_header = "#{algorithm} Credential=#{aws_access_key}/#{credential_scope}, SignedHeaders=#{signed_headers}, Signature=#{signature}"

        return {endpoint: endpoint ,authorization_header: authorization_header, amz_date: amz_date}
    end
end