## Earthquake JSON API

This api provides json access to the USGS worldwide earthquake data set. This
data is in real time and updated every minute.

## Routes
These are the paths to access various tasks within the api

### /
Returns a info page about the API and how many earthquakes are currently tracked

### /earthquakes.json

Returns the entire set of data along with a count of the number of earthquakes

### /earthquakes.json?param=value 

Returns the set of earthquakes filtered by the parameters passed. Multiple parameters can be specified using normal query parameter structure.

Valid parameters include:

| Parameter | Query Example | Description |
| --------- | ----------- | ---------- |
| source | `/earthquakes.json?source=nc` | the source of the occurence, typically the state or country code |
| eqid | `/earthquakes.json?eqid=123456` | the earthquake id of the occurence |
| version | `/earthquakes.json?version=1` |
| occured_at | `/earthquakes.json?occured_at=123456` | the Date Time of the  occurence in UNIX time format |
| latitude | `/earthquakes.json?latitude=39.1234` | the latitude of the occurence |
| longitude | `/earthquakes.json?longitude=24.1345` | the longitude of the  occurence |
| magnitude | `/earthquakes.json?magnitude=1.5` | the magnitude of the occurence |
| depth | `/earthquakes.json?depth=0.8` | the depth of the occurenct |
| nst | `/earthquakes.json?nst=11` |
| region | `/earthquakes.json?region=Nevada` | the region of the occurence |
| on | `/earthquakes.json?on=123456` | the list of occurences for that day in UNIX  time |
| since | `/earthquakes.json?since=123456` | the list of occurences since the time  specified in UNIX time |
| over | `/earthquakes.json?over=1.5` | the list of occurences over the specified  magnitude |
| near | `/earthquakes.json?near=36.6702,-114.8870` | the list of occurences within 5 miles of the specified coordinates |

### /import

Manually import and queue continuous imports of realtime earthquake data


