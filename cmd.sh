
# has to be STP Pinot
mvn clean install -DskipTests -Pbin-dist -Dcheckstyle.skip  -Denforcer.skip=true -Dlicense.skip=true -T
jdk 11; .m2; 
cd /Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-distribution-pkg

#start each component one by one. 
#zookeeper
export JAVA_OPTS="-Xms1G -Xmx2G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-zookeper.log"
./bin/pinot-admin.sh StartZookeeper -zkPort 2191

#controller
export JAVA_OPTS="-Xms1G -Xmx3G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-controller.log"
./bin/pinot-admin.sh StartController -zkAddress localhost:2191  -controllerPort 9000

#Broker
export JAVA_OPTS="-Xms1G -Xmx3G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-broker.log"
./bin/pinot-admin.sh StartBroker  -zkAddress localhost:2191 

#Server 
export JAVA_OPTS="-Xms1G -Xmx4G -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -Xloggc:gc-pinot-server.log"
./bin/pinot-admin.sh StartServer -zkAddress localhost:2191

#start Kafka 
./bin/pinot-admin.sh  StartKafka -zkAddress=localhost:2191/kafka -port 19092

# create schema and table config; 
# on UI;  

#create segments
/Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-distribution-pkg/bin/pinot-admin.sh CreateSegment -dataDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/rawDataSimple -outDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/outputSimple -tableConfigFile /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/simpleMeetup_realtime_table_config.json -schemaFile /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/simpleMeetup_schema.json -overwrite -format JSON

# Upload segments: 
/Users/zhenyunzhuang/workspace/startree-pinot/startree-distribution/target/startree-distribution-pkg/bin/pinot-admin.sh UploadSegment -controllerHost localhost -controllerPort 9000 -tableName simpleMeetup -tableType REALTIME -segmentDir /Users/zhenyunzhuang/workspace/z-tests/pinotUpsert/localMac/outputSimple

#sql query
select event_id, count(*) from simpleMeetup group by event_id order by count(*) desc limit 10
