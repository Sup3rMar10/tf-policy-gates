package main

import rego.v1

# Policies run against the JSON form of a Terraform plan (terraform show -json).

# 1. Files must not be world-writable (the last permission digit grants write: 2, 3, 6 or 7).
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "local_file"
	perm := rc.change.after.file_permission
	regex.match(`[2367]$`, perm)
	msg := sprintf("%s: file_permission %s is world-writable", [rc.address, perm])
}

# 2. Files must stay under out/.
deny contains msg if {
	some rc in input.resource_changes
	rc.type == "local_file"
	name := rc.change.after.filename
	not startswith(name, "./out/")
	msg := sprintf("%s: filename %s is outside ./out/", [rc.address, name])
}
