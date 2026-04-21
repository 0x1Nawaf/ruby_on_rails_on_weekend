env ={}
def load():
    global env 
    config_file = open('config.conf','r')
    configs = config_file.readlines()
    for config_row in configs:
        splitor_arr = config_row.split("=")
        if(len(splitor_arr) > 1):
            env[splitor_arr[0]] = splitor_arr[1].strip()
load()
def get(key):
    try:
        return env[key]
    except:
        return ""