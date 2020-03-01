name "logstash"
description "installs all recipes required to for logstash nodes"
run_list "recipe[default::default_settings],recipe[logstash::kibana_build],recipe[kiban::logstah_config]"