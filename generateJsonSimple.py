#!/opt/homebrew/bin/python3

import random

numKRows = 2*100  # how many K rows
upsertPercent = 50 # how many % of the rows are upserting to old rows with same event id ; 

inputFile = "rawdata.simple"
if numKRows < 1000:
    outputFile = str(numKRows)+"k.json"
else:
    outputFile = str(numKRows/1000)+"m.json"


# Open the input file for reading
with open(inputFile, "r") as input_file:
    # Read the entire file into a string variable
    input_text = input_file.read()

#{"event":{"event_name":"event_name-1062057629"},"group":{"group_topics":[{"topic_name":"topic_name5","urlkey":"http://group-url-711"}],"group_city":"group_city790","group_country":"group_country59","group_id":1931714650437847701,"group_name":"group_name26857140","group_lat":-42.04735223251407,"group_lon":18.51252826737668},"venue":{"venue_name":"venue_name1463550501"},"venue_name":"venue_name1463550501","event_name":"event_name-1062057629","event_id":"key_event_id","event_time":"2023-03-29 18:45:26.394225","group_city":"group_city790","group_country":"group_country59","group_id":1931714650437847701,"group_name":"group_name26857140","group_lat":-42.04735223251407,"group_lon":18.51252826737668,"mtime":1678416326394,"rsvp_id":10,"guests":79,"rsvp_count":10}
# replace : key_event_id to a random number between 1 
# 

keyStr1 = "key_event_id"
keyStr2 = "keymtime"
maxNum = numKRows * 1000 / 100 * (100 - upsertPercent) +1  

# Open the output file for writing
with open(outputFile, "w") as output_file:
    for row in range(numKRows*1000):
        output_text = input_text.replace(keyStr1, "event_id_" + str(random.randint(0, maxNum)))
        strDate = str(random.randint(100, 999)) 
        output_text = output_text.replace(keyStr2, strDate)

        # Write the modified text to the output file
        output_file.write(output_text)


