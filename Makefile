SKIP_SQUASH?=1

.PHONY: build
build:
	SKIP_SQUASH=$(SKIP_SQUASH) hack/build.sh

.PHONY: ocbuild
ocbuild: occheck
	oc process -f openshift/imagestream.yaml -p FRONTNAME=wsweet | oc apply -f-
	BRANCH=`git rev-parse --abbrev-ref HEAD`; \
	if test "$$GIT_DEPLOYMENT_TOKEN"; then \
	    oc process -f openshift/build-with-secret.yaml \
		-p "CASSANDRA_EXPORTER_REPOSITORY_REF=$$BRANCH" \
		-p "FRONTNAME=wsweet" \
		-p "GIT_DEPLOYMENT_TOKEN=$$GIT_DEPLOYMENT_TOKEN" \
		| oc apply -f-; \
	else \
	    oc process -f openshift/build.yaml \
		-p "CASSANDRA_EXPORTER_REPOSITORY_REF=$$BRANCH" \
		-p "FRONTNAME=wsweet" \
		| oc apply -f-; \
	fi

.PHONY: occheck
occheck:
	oc whoami >/dev/null 2>&1 || exit 42

.PHONY: occlean
occlean: occheck
	oc process -f openshift/run-ephemeral.yaml -p FRONTNAME=wsweet | oc delete -f- || true

.PHONY: ocdemoephemeral
ocdemoephemeral: ocbuild
	oc process -f openshift/run-ephemeral.yaml -p FRONTNAME=wsweet | oc apply -f-

.PHONY: ocdemo
ocdemo: ocdemoephemeral

.PHONY: ocpurge
ocpurge: occlean
	oc process -f openshift/build.yaml -p FRONTNAME=wsweet | oc delete -f- || true
	oc process -f openshift/imagestream.yaml -p FRONTNAME=wsweet | oc delete -f- || true
