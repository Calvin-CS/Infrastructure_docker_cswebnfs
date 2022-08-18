#!/bin/bash

helm upgrade \
	--install \
	--create-namespace \
	--atomic \
	--wait \
	--namespace production \
	cswebnfs \
	./cswebnfs \
	--dry-run
