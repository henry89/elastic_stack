name "logstash"
description "installs all recipes required to for logstash nodes"
run_list "recipe[default::default_build]","recipe[kibana::logstash_build]"