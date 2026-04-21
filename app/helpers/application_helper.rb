module ApplicationHelper

  def is_json(string)
      begin
        !!JSON.parse(string)
      rescue
        false
      end
  end

  def add_blob_track_info(data)
    
    track_info = BlobTrackingInfo.create(data)
    return {id: track_info.data_ref_id, size: track_info.size, mimetype: track_info.mimetype}
    
  end
end