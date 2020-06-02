#!/bin/bash
bar='###################################################'
exec 2>&1
date
{ set +x; } 2>/dev/null; echo -e "\$bar\n### java -version\n\$bar\n"; set -x
java -version

{ set +x; } 2>/dev/null; echo -e "\$bar\n### Testing nodetool/dsetool\n\$bar\n"; set -x
nodetool status

{ set +x; } 2>/dev/null; echo -e "\$bar\n### cqlsh - show version\n\$bar\n"; set -x
echo "show version; exit" | cqlsh

cat > getDcName.cqlsh << ENDMSG
select data_center from system.local;
ENDMSG
cqlsh -f getDcName.cqlsh

datacenterName=$(cqlsh -f getDcName.cqlsh | sed -n '4p' | xargs)

echo "DcName =" $datacenterName

cat > test.cqlsh << ENDMSG
CREATE KEYSPACE IF NOT EXISTS test_keyspace WITH replication = {'class':'NetworkTopologyStrategy',$datacenterName:1};
CREATE TABLE IF NOT EXISTS test_keyspace.test_table (id int, color text, PRIMARY KEY (id));
INSERT INTO test_keyspace.test_table (id, color) VALUES (1, 'red');
INSERT INTO test_keyspace.test_table (id, color) VALUES (2, 'blue');
INSERT INTO test_keyspace.test_table (id, color) VALUES (3, 'green');
INSERT INTO test_keyspace.test_table (id, color) VALUES (4, 'yellow');
INSERT INTO test_keyspace.test_table (id, color) VALUES (5, 'orange');
INSERT INTO test_keyspace.test_table (id, color) VALUES (6, 'black');
INSERT INTO test_keyspace.test_table (id, color) VALUES (7, 'brown');
INSERT INTO test_keyspace.test_table (id, color) VALUES (8, 'white');
INSERT INTO test_keyspace.test_table (id, color) VALUES (9, 'purple');
INSERT INTO test_keyspace.test_table (id, color) VALUES (10, 'gray');
ENDMSG

cat test.cqlsh

cqlsh -f test.cqlsh

########## current bug in 4.0.alpha4

cat > select1.cqlsh << ENDMSG
select color from test_keyspace.test_table where id=4;
ENDMSG
cqlsh -f select1.cqlsh


#cqlsh -e 'select color from test_keyspace.test_table where id=4;'
#cqlsh -e 'select color from test_keyspace.test_table where id in(1,4,10);'
