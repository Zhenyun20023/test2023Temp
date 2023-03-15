
# has to be STP Pinot
mvn clean install -DskipTests -Pbin-dist -Dcheckstyle.skip  -Denforcer.skip=true -Dlicense.skip=true -T
jdk 11; .m2; 
cd /Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-pinot-0.13.0-SNAPSHOT-bin/startree-pinot-0.13.0-SNAPSHOT-bin

#start each component one by one. 
#zookeeper
export JAVA_OPTS="-Xms1G -Xmx2G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-zookeper.log"
./bin/pinot-admin.sh StartZookeeper -zkPort 2191

#controller
export JAVA_OPTS="-Xms1G -Xmx3G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-controller.log"
./bin/pinot-admin.sh StartController -zkAddress localhost:2191  -controllerPort 9000 -configOverride pinot.controller.startable.class=ai.startree.service.startable.pinot.controller.StarTreePinotControllerStarter

#Broker
export JAVA_OPTS="-Xms1G -Xmx3G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-broker.log"
./bin/pinot-admin.sh StartBroker  -zkAddress localhost:2191 


#Server 
export JAVA_OPTS="-Xms1G -Xmx4G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-server.log"
./bin/pinot-admin.sh StartServer -zkAddress localhost:2191  -configOverride  pinot.server.startable.class=ai.startree.service.startable.pinot.server.StarTreePinotServerStarter


#start Kafka 
./bin/pinot-admin.sh  StartKafka -zkAddress=localhost:2191/kafka -port 19092

# create schema and table config manually on UI
# enable off-heap on UI table config; 
  "upsertConfig": {
    "mode": "FULL", 
    "metadataManagerClass": "ai.startree.pinot.upsert.rocksdb.RocksDBTableUpsertMetadataManager"
  }
  "routing": {
    "segmentPrunerTypes": ["partition"],
    "instanceSelectorType": "strictReplicaGroup"
  },


#drop dead servers; 
# check zookeeper ideal state and external view; controller; 
# if needed, edit the zk's ideal state (e.g., segment asignments)

#restart server: 
querying returning warning aboout unavailable segments. 
It should have lines with Adding segment and Finished Adding Segment
Also, a lot of performance info can be found in rocksdb logs itself. They are dumped every 5 minutes by default.
for those you need to check; dataDir/tableName/rocksDB/LOG 
Async profiler captures cpu time by default. For RocksDB, it is better if we capture wall time to account for IO waits as well

# generate json files randomized; 
./generateJsonSimple.py 

#create segments
/Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-pinot-0.13.0-SNAPSHOT-bin/startree-pinot-0.13.0-SNAPSHOT-bin/bin/pinot-admin.sh CreateSegment -dataDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/rawDataSimple -outDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/outputSimple -tableConfigFile /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/simpleMeetup_realtime_table_config.json -schemaFile /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/simpleMeetup_schema.json -overwrite -format JSON

# Upload segments: 
/Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-pinot-0.13.0-SNAPSHOT-bin/startree-pinot-0.13.0-SNAPSHOT-bin/bin/pinot-admin.sh UploadSegment -controllerHost localhost -controllerPort 9000 -tableName simpleMeetup -tableType REALTIME -segmentDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/outputSimple

#sql query
select event_id, count(*) from simpleMeetup group by event_id order by count(*) desc limit 10
