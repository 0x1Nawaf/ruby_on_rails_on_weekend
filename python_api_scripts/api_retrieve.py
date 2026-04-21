import requests
import json
import base64
import config

latest_stored_file  = open("stored_data_ref_id.list", "r") 
latest_stored_id = latest_stored_file.readlines().pop()

url = config.get("api_url")+"/blobs/"+latest_stored_id

payload=json.dumps({})

files=[

]

headers={"Content-Type":"application/json", "Accept":"application/json", "Authorization":"Bearer "+config.get("api_token")}

response = requests.request("GET", url, headers=headers, data=payload, files=files)

if(response.status_code!=200):
  print('error ', 'status code ', response.status_code)
else:
  print(response.text)
  json_res = response.json()

  if("id" in json_res):
    file_name = "retrieved/" + json_res['id'] +"."+ json_res['mimetype'].split("/")[1]
    file_obj = open(file_name,'wb')
    file_obj.write(base64.b64decode(json_res['data']))

    print("=================="*2)
    print("check retrieved folder")
    print("=================="*2)

