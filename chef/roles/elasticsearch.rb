name "elasticsearch"
description "installs all recipes required to for elasticsearch nodes"
run_list "recipe[default::default_build]","recipe[elasticsearch::elasticsearch_build]"
