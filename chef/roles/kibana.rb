name "kibana"
description "installs all recipes required to for kibana nodes"
run_list "recipe[default::default_settings],recipe[kibana::kibana_build],recipe[kibana::nginx_setup]"