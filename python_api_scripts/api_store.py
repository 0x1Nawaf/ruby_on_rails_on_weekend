import requests
import json
import base64
import random
import config

ext_list=['jpg', 'gif']

url = config.get("api_url")+"/blobs"


file_obj = open("yes."+ext_list[random.randint(0, 1)],'rb')
base64_encode = base64.b64encode(file_obj.read())

payload=json.dumps({"storing_type":"s3", "data": base64_encode.decode()})

files=[]

headers={"Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+config.get("api_token")}

response = requests.request("POST", url, headers=headers, data=payload, files=files)

if(response.status_code!=200):
  print('error ', 'status code ', response.status_code)
else:
  print(response.text)
  json_res = response.json()

  if("id" in json_res):
    file = open("stored_data_ref_id.list", "a")
    file.write("\n"+json_res["id"])
