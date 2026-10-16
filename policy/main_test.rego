package main

import rego.v1

plan(perm, name) := {"resource_changes": [{
	"address": "local_file.conf",
	"type": "local_file",
	"change": {"after": {"file_permission": perm, "filename": name}},
}]}

test_good_plan_passes if {
	count(deny) == 0 with input as plan("0640", "./out/service.conf")
}

test_world_writable_denied if {
	count(deny) == 1 with input as plan("0777", "./out/service.conf")
}

test_path_escape_denied if {
	count(deny) == 1 with input as plan("0640", "./../escape.conf")
}

test_both_violations_reported if {
	count(deny) == 2 with input as plan("0666", "./../x")
}
