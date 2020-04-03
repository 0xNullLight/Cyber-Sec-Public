# tested on Python 2.7

import json

def getJSON(filePathAndName):
    with open(filePathAndName, 'r') as fp:
        return json.load(fp)

# Example of returning just JSON
# jsonFile = getJSON('./test.json') # Uncomment this line
# It gets returned as a dictionary.

# Example of getting a list from a JSON file
# test.json looks like:
# {
#   "photos" : [
#           "test1",
#           "test2"
#       ]
# }

listOfPhotos = getJSON('./test.json').get('photos',[])
# If 'photos' is not in the JSON file then it would set it to []
