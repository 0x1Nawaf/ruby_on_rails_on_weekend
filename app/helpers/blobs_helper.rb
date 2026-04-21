module BlobsHelper

    #store
    def store_object(user, request)
        begin
            if is_json(request.raw_post) == true
        
                

                json_req = JSON.parse(request.raw_post)
                data = Base64.decode64(Base64.encode64(json_req["data"]))
                bytes = Base64.decode64(data)
                size = bytes.bytesize
                mimetype = Marcel::MimeType.for(bytes)
                complex_file_name = Digest::SHA1.hexdigest( "#{(user.id).to_s}-#{(bytes).to_s}#{(Time.now.to_i).to_s}")
    


                #save the prev vars for passing it to other storing funcs
                storing_data = {
                    user: user,
                    json_req: json_req,
                    data: data,
                    bytes: bytes,
                    size: size,
                    mimetype: mimetype,
                    complex_file_name: complex_file_name
                }

                path = nil
                storing_type = "local"

                if json_req["storing_type"]         == "s3"
                    
                    storing_type = "s3"
                    path = s3_store(storing_data)


                elsif json_req["storing_type"]      == "db"
                    
                    storing_type = "db"
                    path = db_store(storing_data)

                elsif json_req["storing_type"]      == "ftp"

                    storing_type = "ftp"
                    path = ftp_store(storing_data)

                else

                    path = local_store(storing_data)
                    
                end

                if path == nil
                    return nil
                end

                return add_blob_track_info({data_ref_id: complex_file_name, size: size, user_id: user.id, path: path, mimetype: mimetype, storing_type: storing_type})
            end
        rescue StandardError
            #TODO: TRY TO FIX IF NECESSARY
        end
        return nil
    end

    ##retrieve object
    def retrieve_object(user, data_id)
        begin
            track_info = BlobTrackingInfo.where(user_id: user.id).find_by(data_ref_id: data_id)
            if track_info == nil
                return nil
            end

            binary_data = ""
            data = nil
            not_binary = false
            if track_info.storing_type == "s3"
                binary_data = retrieve_from_s3(track_info.path)

            elsif track_info.storing_type == "db"

                not_binary = true
                data = retrieve_from_db(track_info.data_ref_id)

            elsif track_info.storing_type == "ftp"
                binary_data = retrieve_from_ftp(track_info.path)

            elsif track_info.storing_type == "local"
                binary_data = retrieve_from_local(track_info.path)

            end

            if not_binary == false

                data = Base64.encode64(binary_data)
            end

            return {id: data_id, data: data, mimetype: track_info.mimetype, size: track_info.size, created_at: track_info.created_at}
        rescue StandardError
            #TODO: TRY TO FIX IF NECESSARY
        end
        return nil
    end

    private
    
    #local funcs

    #--------------------store funcs----------------------------
        def s3_store(storing_data)

            tmp_path = local_store(storing_data, "tmp/")
            
            file_name = "#{storing_data[:complex_file_name]}.#{storing_data[:mimetype].split("/")[1]}"
            
            s3_session_data = s3_session_start(file_name, "PUT")

            #reading file (as binary) 
            file = File.open(tmp_path, "rb")
                file_data = file.read
            file.close
            
            connection = Faraday.new(url: s3_session_data[:endpoint]) do |conn|
                conn.headers["x-amz-content-sha256"] = "UNSIGNED-PAYLOAD"
                conn.headers["x-amz-date"] = s3_session_data[:amz_date]
                conn.headers["Authorization"] = s3_session_data[:authorization_header]
                # conn.headers["Content-Type"] = "application/octet-stream"
                # conn.headers["Content-Length"] = (file_data.bytesize).to_s

            end

            response = connection.put("", file_data)
            File.delete(tmp_path)

            if response.status != 200
                return nil
            end

            return file_name
        end


        def db_store(storing_data)
            BlobDataStorage.create({data_ref_id: storing_data[:complex_file_name], data: storing_data[:data]})

            return "db"
        end

        def local_store(storing_data, main_path="storage/uploaded/")
            path = "#{main_path}#{storing_data[:complex_file_name]}.#{storing_data[:mimetype].split("/")[1]}"

            File.open(path , "wb") do |file|
                file.write(storing_data[:bytes])
            end
            
            return  path
        end


        def ftp_store(storing_data)

            #dlp is providing  public access ftp server only saving the files for 10 min
            #   server_name: "ftp.dlptest.com",
            #   username: "dlpuser",
            #   password: "rNrKYTX9g7z3RgJRmxWuGHbeu",
            #dlp is providing  public access ftp server only saving the files for 10 min


            tmp_path = local_store(storing_data, "tmp/")
            
            file_name = "#{storing_data[:complex_file_name]}.#{storing_data[:mimetype].split("/")[1]}"
            
            #reading file (as binary) 
            file = File.open(tmp_path, "rb")
                file_data = file.read
            file.close
            
            Net::FTP.open("ftp.dlptest.com", username: "dlpuser",
            password: "rNrKYTX9g7z3RgJRmxWuGHbeu") do |ftp|
                ftp.putbinaryfile(tmp_path, file_name)
            end


            File.delete(tmp_path)

            return file_name
        end

    #--------------------retrieve funcs----------------------------
        def retrieve_from_s3(path)

            s3_session_data = s3_session_start(path, "GET")

            connection = Faraday.new(url: s3_session_data[:endpoint]) do |conn|
                conn.headers["x-amz-content-sha256"] = "UNSIGNED-PAYLOAD"
                conn.headers["x-amz-date"] = s3_session_data[:amz_date]
                conn.headers["Authorization"] = s3_session_data[:authorization_header]
                end

            response = connection.get("")

            if response.status != 200
                return nil
            end

            return response.body
        end
        
        def retrieve_from_db(data_ref_id)
            blob = BlobDataStorage.find_by(data_ref_id: data_ref_id)

            if blob == nil
                return nil
            end
            return blob.data
        end


        def retrieve_from_ftp(path)
            #dlp is providing  public access ftp server only saving the files for 10 min
            #   server_name: "ftp.dlptest.com",
            #   username: "dlpuser",
            #   password: "rNrKYTX9g7z3RgJRmxWuGHbeu",
            #dlp is providing  public access ftp server only saving the files for 10 min

            tmp_path = "tmp/"<< Digest::MD5.hexdigest(path)
            
            Net::FTP.open("ftp.dlptest.com", username:"dlpuser",
            password: "rNrKYTX9g7z3RgJRmxWuGHbeu") do |ftp|
                ftp.getbinaryfile(path,
                tmp_path)
            end 

            binary = (File.read(tmp_path))
            File.delete(tmp_path)

            return binary
        end

        def retrieve_from_local(path)
            return (File.read(path))
        end











end
