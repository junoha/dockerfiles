# Elasticsearch 7.9.1 in docker

## Install Vietnamese Analysis Plugin

https://github.com/duydo/elasticsearch-analysis-vietnamese

Follow this steps  
https://duydo.me/how-to-build-elasticsearch-vietnamese-analysis-plugin/

Install vn-nlp-libraries.
```shell-session
$ cd es
$ git clone https://github.com/duydo/vn-nlp-libraries.git
$ cd vn-nlp-libraries/nlp-parent
$ mvn install

$ cd ../../
```

Install lasticsearch-analysis-vietnamese.
```shell-session
$ git clone https://github.com/duydo/elasticsearch-analysis-vietnamese.git
```

Need to cherry pick commit on 6.8 branch.  
* https://github.com/duydo/elasticsearch-analysis-vietnamese/issues/85
* https://github.com/duydo/elasticsearch-analysis-vietnamese/commit/2a9f84d1035c7e675c88e026f9d49f64eb2378df

```shell-session
$ cd elasticsearch-analysis-vietnamese
$ git checkout origin/feature/v6.8.2
$ git log

...
commit 2a9f84d1035c7e675c88e026f9d49f64eb2378df
Merge: 23b2dca adbfdab
Author: Duy Do <doquocduy@gmail.com>
Date:   Mon Jun 8 21:28:57 2020 +0700

    Merge pull request #83 from MunKeat/feature/v6.8.2-accesscontrolexception-fix

    Fix AccessControlException (accessDeclaredMembers) for v6

commit adbfdabf621ab62563769dc6faaf01ae13cacac0
Author: MunKeat <MunKeat@users.noreply.github.com>
Date:   Thu Jun 4 20:54:23 2020 +0800

    Remove unused code
...

$ git rev-parse 2a9f84d1035c7e675c88e026f9d49f64eb2378df^1
23b2dcab8d7834b5c206965d569bba392a5dd29d

$ git rev-parse 2a9f84d1035c7e675c88e026f9d49f64eb2378df^2
adbfdabf621ab62563769dc6faaf01ae13cacac0

# ===> parent number is 1

# cherry pick like issues#85
$ git checkout master
$ git cherry-pick -m 1 2a9f84d1035c7e675c88e026f9d49f64eb2378df
```

Create package.
```shell-session
$ git diff
diff --git a/pom.xml b/pom.xml
index 5f68ec6..184ed69 100644
--- a/pom.xml
+++ b/pom.xml
@@ -3,7 +3,7 @@
     <modelVersion>4.0.0</modelVersion>
     <groupId>org.elasticsearch</groupId>
     <artifactId>elasticsearch-analysis-vietnamese</artifactId>
-    <version>7.5.1</version>
+    <version>7.9.1</version>
     <packaging>jar</packaging>
     <name>elasticsearch-analysis-vietnamese</name>
     <url>https://github.com/duydo/elasticsearch-analysis-vietnamese/</url>
@@ -30,8 +30,8 @@
     </scm>
     <properties>
         <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
-        <project.build.java.version>1.8</project.build.java.version>
-        <elasticsearch.version>7.5.1</elasticsearch.version>
+        <project.build.java.version>1.14</project.build.java.version>
+        <elasticsearch.version>7.9.1</elasticsearch.version>
         <log4j.version>2.13.3</log4j.version>
     </properties>
     <dependencies>


$ mvn clean package -Dmaven.test.skip=true
$ cd ../../
$ ls
README.md          docker-compose.yml es
```

Start Elasticsearch and Kibana.
```shell-session
$ docker-compose up -d

$ curl localhost:9200/_cat/plugins
84c24cec2e31 elasticsearch-analysis-vietnamese 7.9.1
```

## Check stdout logs
```shell-session
$ docker container logs -f es-custom_elasticsearch_1

# PUT aaa
{"type": "server", "timestamp": "2021-03-29T15:05:15,968Z", "level": "INFO", "component": "stdout", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "Loading unigram model...OK", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }
{"type": "server", "timestamp": "2021-03-29T15:05:16,008Z", "level": "INFO", "component": "stdout", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "Loading unigram model...OK", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }

# -> Twice "Loading unigram model...OK"

# PUT aaa/_mapping
{"type": "server", "timestamp": "2021-03-29T15:12:18,448Z", "level": "INFO", "component": "o.e.c.m.MetadataMappingService", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "[aaa/72Z4TyVsR5mCFOGAe9BZjA] create_mapping [_doc]", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }

# PUT aaa/_mapping
{"type": "server", "timestamp": "2021-03-29T15:12:21,644Z", "level": "INFO", "component": "stdout", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "Loading unigram model...OK", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }
{"type": "server", "timestamp": "2021-03-29T15:12:21,691Z", "level": "INFO", "component": "stdout", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "Loading unigram model...OK", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }

# -> Twice "Loading unigram model...OK"

# DELETE aaa
{"type": "server", "timestamp": "2021-03-29T15:05:16,555Z", "level": "INFO", "component": "o.e.c.m.MetadataDeleteIndexService", "cluster.name": "docker-cluster", "node.name": "84c24cec2e31", "message": "[aaa/-eWXz6ldSOCOdzt_BiJYQw] deleting index", "cluster.uuid": "94Dc9H8SQZ2KyUBol9P5Kg", "node.id": "vC7GdfacTrKyPVNW87OIWg"  }
```

## Login to ES container
https://github.com/elastic/elasticsearch/issues/50727

```shell-session
$ docker container exec -u 1000:0 -it es-custom_elasticsearch_1 bash

[elasticsearch@84c24cec2e31 ~]$ jdk/bin/java -version
openjdk version "14.0.1" 2020-04-14
OpenJDK Runtime Environment AdoptOpenJDK (build 14.0.1+7)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 14.0.1+7, mixed mode, sharing)


# Check Elasticsearch process id
[elasticsearch@19501999158a ~]$ jdk/bin/jps
9 Elasticsearch
317 Jps


# JVM command parameter
[elasticsearch@19501999158a ~]$ jdk/bin/jcmd 9 VM.command_line
9:
VM Arguments:
jvm_args: -Xshare:auto -Des.networkaddress.cache.ttl=60 -Des.networkaddress.cache.negative.ttl=10 -XX:+AlwaysPreTouch -Xss1m -Djava.awt.headless=true -Dfile.encoding=UTF-8 -Djna.nosys=true -XX:-OmitStackTraceInFastThrow -XX:+ShowCodeDetailsInExceptionMessages -Dio.netty.noUnsafe=true -Dio.netty.noKeySetOptimization=true -Dio.netty.recycler.maxCapacityPerThread=0 -Dio.netty.allocator.numDirectArenas=0 -Dlog4j.shutdownHookEnabled=false -Dlog4j2.disable.jmx=true -Djava.locale.providers=SPI,COMPAT -Xms1g -Xmx1g -XX:+UseG1GC -XX:G1ReservePercent=25 -XX:InitiatingHeapOccupancyPercent=30 -Djava.io.tmpdir=/tmp/elasticsearch-16175062007526238065 -XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=data -XX:ErrorFile=logs/hs_err_pid%p.log -Xlog:gc*,gc+age=trace,safepoint:file=logs/gc.log:utctime,pid,tags:filecount=32,filesize=64m -Des.cgroups.hierarchy.override=/ -Xms512m -Xmx512m -XX:MaxDirectMemorySize=268435456 -Des.path.home=/usr/share/elasticsearch -Des.path.conf=/usr/share/elasticsearch/config -Des.distribution.flavor=default -Des.distribution.type=docker -Des.bundled_jdk=true
java_command: org.elasticsearch.bootstrap.Elasticsearch -Ecluster.name=docker-cluster -Ediscovery.type=single-node -Ebootstrap.memory_lock=true
java_class_path (initial): /usr/share/elasticsearch/lib/lucene-spatial3d-8.6.2.jar:/usr/share/elasticsearch/lib/hppc-0.8.1.jar:/usr/share/elasticsearch/lib/log4j-core-2.11.1.jar:/usr/share/elasticsearch/lib/lucene-core-8.6.2.jar:/usr/share/elasticsearch/lib/jackson-dataformat-yaml-2.10.4.jar:/usr/share/elasticsearch/lib/lucene-highlighter-8.6.2.jar:/usr/share/elasticsearch/lib/t-digest-3.2.jar:/usr/share/elasticsearch/lib/lucene-suggest-8.6.2.jar:/usr/share/elasticsearch/lib/log4j-api-2.11.1.jar:/usr/share/elasticsearch/lib/jopt-simple-5.0.2.jar:/usr/share/elasticsearch/lib/jackson-dataformat-cbor-2.10.4.jar:/usr/share/elasticsearch/lib/lucene-join-8.6.2.jar:/usr/share/elasticsearch/lib/elasticsearch-7.9.1.jar:/usr/share/elasticsearch/lib/lucene-misc-8.6.2.jar:/usr/share/elasticsearch/lib/lucene-grouping-8.6.2.jar:/usr/share/elasticsearch/lib/elasticsearch-launchers-7.9.1.jar:/usr/share/elasticsearch/lib/java-version-checker-7.9.1.jar:/usr/share/elasticsearch/lib/lucene-analyzers-common-8.6.2.jar:/usr/share/elasticsearch/lib/lucene-memory-8.6.2.jar:/usr/share/elasticsearch/lib/HdrHistogram-2.1.9.jar:/usr/share/elasticsearch/lib/lucene-backward-codecs-8.6.2.jar:/usr/share/elasticsearch/lib/jackson-core-2.10.4.jar:/usr/share/elasticsearch/lib/lucene-queries-8.6.2.jar:/usr/share/elasticsearch/lib/elasticsearch-plugin-classloader-7.9.1.jar:/usr/share/elasticsearch/lib/lucene-spatial-extras-8.6.2.jar:/usr/share/elasticsearch/lib/elasticsearch-core-7.9.1.jar:/usr/share/elasticsearch/lib/lucene-sandbox-8.6.2.jar:/usr/share/elasticsearch/lib/jts-core-1.15.0.jar:/usr/share/elasticsearch/lib/jackson-dataformat-smile-2.10.4.jar:/usr/share/elasticsearch/lib/jna-5.5.0.jar:/usr/share/elasticsearch/lib/elasticsearch-secure-sm-7.9.1.jar:/usr/share/elasticsearch/lib/spatial4j-0.7.jar:/usr/share/elasticsearch/lib/elasticsearch-x-content-7.9.1.jar:/usr/share/elasticsearch/lib/elasticsearch-cli-7.9.1.jar:/usr/share/elasticsearch/lib/lucene-queryparser-8.6.2.jar:/usr/share/elasticsear
Launcher Type: SUN_STANDARD
```

Perf test on notebook  
http://localhost:8888/notebooks/work/perf-test.ipynb

```
# Heap histogram
[elasticsearch@19501999158a ~]$ jdk/bin/jcmd 9 GC.class_histogram -all | head -30
9:
 num     #instances         #bytes  class name (module)
-------------------------------------------------------
   1:       1603468       58308472  [B (java.base@14.0.1)
   2:       1554442       37306608  java.lang.String (java.base@14.0.1)
   3:        708485       22671520  java.util.HashMap$Node (java.base@14.0.1)
   4:        682120       16370880  vn.hus.nlp.lexicon.jaxb.W
   5:        114076       10323336  [Ljava.lang.Object; (java.base@14.0.1)
   6:         19950        6128880  [I (java.base@14.0.1)
   7:         39968        5894000  [Ljava.util.HashMap$Node; (java.base@14.0.1)
   8:         14873        5697424  [C (java.base@14.0.1)
   9:         58659        2815632  java.util.HashMap (java.base@14.0.1)
  10:         22914        2687872  java.lang.Class (java.base@14.0.1)
  11:         81124        2595968  java.util.concurrent.ConcurrentHashMap$Node (java.base@14.0.1)
  12:         78919        2525408  vn.hus.nlp.fsm.Transition
  13:        100482        2411568  java.util.ArrayList (java.base@14.0.1)
  14:         56410        1805120  java.util.concurrent.atomic.LongAdder (java.base@14.0.1)
  15:         92979        1487664  java.lang.Integer (java.base@14.0.1)
  16:         36604        1171328  sun.nio.fs.UnixPath (java.base@14.0.1)
  17:         34676        1109632  java.util.Collections$UnmodifiableMap (java.base@14.0.1)
  18:         44106        1058544  vn.hus.nlp.fsm.State
  19:         36979         887496  org.elasticsearch.common.util.concurrent.ReleasableLock
  20:         18460         886080  java.util.concurrent.locks.ReentrantReadWriteLock$NonfairSync (java.base@14.0.1)
  21:          1427         773200  [Ljava.util.concurrent.ConcurrentHashMap$Node; (java.base@14.0.1)
  22:         48170         770720  java.lang.Object (java.base@14.0.1)
  23:         14214         682272  java.lang.invoke.MemberName (java.base@14.0.1)
  24:         18432         589824  org.elasticsearch.common.cache.Cache$CacheSegment
  25:          6462         568656  java.lang.reflect.Method (java.base@14.0.1)
  26:          1581         488208  [J (java.base@14.0.1)
  27:          1917         478048  [Z (java.base@14.0.1)


# Get heap dump
[elasticsearch@19501999158a ~]$ jdk/bin/jcmd 9 GC.heap_dump hdump.hprof
9:
Dumping heap to hdump.hprof ...
Heap dump file created [215895845 bytes in 2.411 secs]

# On local
$ docker container cp es-custom_elasticsearch_1:/usr/share/elasticsearch/hdump.hprof ./heap_dump/hdump.hprof
```

Analyze heap dump with [MAT](http://www.eclipse.org/mat/)