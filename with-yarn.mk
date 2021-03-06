# JS_YARN_INSTALL_ARGS is a set of arguments passed to "yarn install"
JS_YARN_INSTALL_ARGS ?= --pure-lockfile

ifneq ($(MF_NON_INTERACTIVE),)
	JS_YARN_INSTALL_ARGS += --non-interactive --no-progress
endif

################################################################################

# Ensure that dependencies are installed before attempting to build a Docker
# image.
DOCKER_BUILD_REQ += package.json yarn.lock

################################################################################

# set-package-version --- Sets the version field in package.json to a semver
# representation of the HEAD commit.
.PHONY: set-package-version
set-package-version:
	yarn version --no-git-tag-version --new-version "$(SEMVER)"

################################################################################

node_modules: yarn.lock
	yarn install $(JS_YARN_INSTALL_ARGS)

	@touch "$@"

yarn.lock: package.json
	yarn install $(JS_YARN_INSTALL_ARGS)

	@touch "$@"

package.json:
ifeq ($(wildcard package.json),)
	cp "$(MF_ROOT)/pkg/js/v1/etc/init.package.json" "$(MF_PROJECT_ROOT)/package.json"
endif

artifacts/yarn/production/node_modules: yarn.lock
	yarn install $(JS_YARN_INSTALL_ARGS) --production --modules-folder "$@"
