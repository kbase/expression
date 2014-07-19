TOP_DIR = ../..
DEPLOY_RUNTIME ?= /kb/runtime
TARGET ?= /kb/deployment
SERVICE_SPEC = KBaseExpression.spec 
SERVICE_NAME = KBaseExpression
SERVICE_PSGI_FILE = $(SERVICE_NAME).psgi
ROOT_DEV_MODULE_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
KB_DEPLOYMENT_CONFIG ?=$(TARGET)/deployment.cfg
#KB_DEPLOYMENT_CONFIG ?= $(ROOT_DEV_MODULE_DIR)/deploy.cfg
SERVICE_CONFIG_NAME = KBaseExpression
SERVICE_PORT = 7075

include $(TOP_DIR)/tools/Makefile.common

# to wrap scripts and deploy them to $(TARGET)/bin using tools in
# the dev_container. right now, these vars are defined in
# Makefile.common, so it's redundant here.
TOOLS_DIR = $(TOP_DIR)/tools
WRAP_PERL_TOOL = wrap_perl
WRAP_PERL_SCRIPT = bash $(TOOLS_DIR)/$(WRAP_PERL_TOOL).sh
SRC_PERL = $(wildcard scripts/*.pl)

# You can change these if you are putting your tests somewhere
# else or if you are not using the standard .t suffix
CLIENT_TESTS = $(wildcard t/client-tests/*.t)
SCRIPTS_TESTS = $(wildcard t/script-tests/*.t)
SERVER_TESTS = $(wildcard t/server-tests/*.t)

SERVICE = KBaseExpression
$(SERVICE_DIR) ?= /kb/deployment/services/$(SERVICE)
PID_FILE = $(SERVICE_DIR)/service.pid
ACCESS_LOG_FILE = $(SERVICE_DIR)/log/access.log
ERR_LOG_FILE = $(SERVICE_DIR)/log/error.log

# This is a very client-centric view of release engineering.
# We assume our primary product for the community is the client
# libraries, command line interfaces, and the related documentation
# from which specific science applications can be built.
#
# A service is composed of a client and a server, each of which
# should be independently deployable. Clients are composed of
# an application programming interface (API) and a command line
# interface (CLI). In our make targets, deploy-service deploys
# the server, deploy-client deploys the application
# programming interface libraries, and deploy-scripts deploys
# the command line interface (usually scripts written in a
# scripting language but java executables also qualify), and the
# deploy target would be equivelant to deploying a service (client
# libs, scripts, and server).
#
# Because the deployment of the server side code depends on the
# specific software module being deployed, the strategy needs
# to be one that leaves this decision to the module developer.
# This is done by having the deploy target depend on the
# deploy-service target. The module developer who chooses for
# good reason not to deploy the server with the client simply
# manages this dependancy accordingly. One option is to have
# a deploy-service target that does nothing, the other is to
# remove the dependancy from the deploy target.
#
# A smiliar naming convention is used for tests. 


default:

# Test Section

test:	test-client test-scripts test-service
	@echo "make test should be run from the expression directory (where you checked it out)"
	@echo "running client and script tests"

# test-all is deprecated. 
# test-all: test-client test-scripts test-service
#
# test-client: This is a test of a client library. If it is a
# client-server module, then it should be run against a running
# server. You can say that this also tests the server, and I
# agree. You can add a test-service dependancy to the test-client
# target if it makes sense to you. This test example assumes there is
# already a tested running server.
test-client:
	# run each test
	for t in $(CLIENT_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

# test-scripts: A script test should test the command line scripts. If
# the script is a client in a client-server architecture, then there
# should be tests against a running server. You can add a test-service
# dependency to the test-client target. You could also add a
# deploy-service and start-server dependancy to the test-scripts
# target if it makes sense to you. Future versions of the makefiles
# for services will move in this direction.
test-scripts:
	# run each test
	for t in $(SCRIPTS_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

# test-service: A server test should not rely on the client libraries
# or scripts--you should not have a test-service target that depends
# on the test-client or test-scripts targets. Otherwise, a circular
# dependency graph could result.
test-service:
	# run each test
	for t in $(SERVER_TESTS) ; do \
		if [ -f $$t ] ; then \
			$(DEPLOY_RUNTIME)/bin/perl $$t ; \
			if [ $$? -ne 0 ] ; then \
				exit 1 ; \
			fi \
		fi \
	done

# Deployment:
# 
# We are assuming our primary products to the community are
# client side application programming interface libraries and a
# command line interface (scripts). The deployment of client
# artifacts should not be dependent on deployment of a server,
# although we recommend deploying the server code with the
# client code when the deploy target is executed. If you have
# good reason not to deploy the server at the same time as the
# client, just delete the dependancy on deploy-service. It is
# important to note that you must have a deploy-service target
# even if there is no server side code to deploy.

deploy: deploy-client deploy-service

# deploy-all deploys client *and* server. This target is deprecated
# and should be replaced by the deploy target.

deploy-all: deploy-client deploy-service

# deploy-client should deploy the client artifacts, mainly
# the application programming interface libraries, command
# line scripts, and associated reference documentation.

deploy-client: deploy-libs deploy-scripts deploy-docs

# The deploy-libs and deploy-scripts targets are used to recognize
# and delineate the client types, mainly a set of libraries that
# implement an application programming interface and a set of 
# command line scripts that provide command-based execution of
# individual API functions and aggregated sets of API functions.

deploy-libs: build-libs
	rsync --exclude '*.bak*' -arv lib/. $(TARGET)/lib/.

# Deploying scripts needs some special care. They need to run
# in a certain runtime environment. Users should not have
# to modify their user environments to run kbase scripts, other
# than just sourcing a single user-env script. The creation
# of this user-env script is the responsibility of the code
# that builds all the kbase modules. In the code below, we
# run a script in the dev_container tools directory that 
# wraps perl scripts. The name of the perl wrapper script is
# kept in the WRAP_PERL_SCRIPT make variable. This script
# requires some information that is passed to it by way
# of exported environment variables in the bash script below.
#
# What does it mean to wrap a perl script? To wrap a perl
# script means that a bash script is created that sets
# all required environment variables and then calls the perl
# script using the perl interperter in the kbase runtime.
# For this to work, both the actual script and the newly 
# created shell script have to be deployed. When a perl
# script is wrapped, it is first copied to TARGET/plbin.
# The shell script can now be created because the necessary
# environment variables are known and the location of the
# script is known. 

deploy-scripts:
	export KB_TOP=$(TARGET); \
	export KB_RUNTIME=$(DEPLOY_RUNTIME); \
	export KB_PERL_PATH=$(TARGET)/lib bash; \
	for src in $(SRC_PERL); do \
		basefile=`basename $$src`; \
		base=`basename $$src .pl`; \
		echo install $$src $$base; \
		cp $$src $(TARGET)/plbin; \
		$(WRAP_PERL_SCRIPT) "$(TARGET)/plbin/$$basefile" $(TARGET)/bin/$$base; \
	done

# Deploying a service refers to to deploying the capability
# to run a service. Becuase service code is often deployed 
# as part of the libs, meaning service code gets deployed
# when deploy-libs is called, the deploy-service target is
# generally concerned with the service start and stop scripts.

deploy-service: deploy-service-scripts

# Deploying docs here refers to the deployment of documentation
# of the API. We'll include a description of deploying documentation
# of command line interface scripts when we have a better understanding of
# how to standardize and automate CLI documentation.

deploy-docs: build-docs
	-mkdir -p $(TARGET)/services/$(SERVICE_NAME)/webroot/.
	cp docs/*.html $(TARGET)/services/$(SERVICE_NAME)/webroot/.

# The location of the Client.pm file depends on the --client param
# that is provided to the compile_typespec command. The
# compile_typespec command is called in the build-libs target.

build-docs: compile-docs
	pod2html --infile=lib/Bio/KBase/$(SERVICE_NAME)/$(SERVICE_NAME)Client.pm --outfile=docs/$(SERVICE_NAME).html

# Use the compile-docs target if you want to unlink the generation of
# the docs from the generation of the libs. Not recommended, but there
# could be a reason for it that I'm not seeing.
# The compile-docs target should depend on build-libs so that we are
# assured of having a set of documentation that is based on the latest
# type spec.

compile-docs: build-libs

# build-libs should be dependent on the type specification and the
# type compiler. Building the libs in this way means that you don't
# need to put automatically generated code in a source code version
# control repository (e.g., cvs, git). It also ensures that you always
# have the most up-to-date libs and documentation if your compile-docs
# target depends on the compiled libs.
#		--scripts scripts \

build-libs:
	compile_typespec \
		--psgi $(SERVICE_NAME).psgi \
		--impl Bio::KBase::$(SERVICE_NAME)::$(SERVICE_NAME)Impl \
		--service Bio::KBase::$(SERVICE_NAME)::Service \
		--client Bio::KBase::$(SERVICE_NAME)::KBaseExpressionClient \
		--py biokbase/$(SERVICE_NAME)/KBaseExpressionClient \
		--js javascript/$(SERVICE_NAME)/KBaseExpressionClient \
		$(SERVICE_SPEC) lib

# creates start/stop/reboot scripts and copies them to the deployment target
deploy-service-scripts:	
	# First create the start script (should be a better way to do this...)
	echo '#!/bin/sh' > ./start_service
	echo "echo starting $(SERVICE) service." >> ./start_service
	echo 'export PERL5LIB=$$PERL5LIB:$(TARGET)/lib' >> ./start_service
	echo 'export KB_DEPLOYMENT_CONFIG=$(KB_DEPLOYMENT_CONFIG)' >> ./start_service
	echo 'export KB_SERVICE_NAME=$(SERVICE_CONFIG_NAME)' >> ./start_service
	echo '#uncomment to debug: export STARMAN_DEBUG=1' >> ./start_service
	echo "$(DEPLOY_RUNTIME)/bin/starman --listen :$(SERVICE_PORT) --pid $(PID_FILE) --daemonize \\" >> ./start_service
	echo "  --access-log $(ACCESS_LOG_FILE) \\" >>./start_service
	echo "  --error-log $(ERR_LOG_FILE) \\" >> ./start_service
	echo "  $(TARGET)/lib/$(SERVICE_PSGI_FILE)" >> ./start_service
	echo "echo $(SERVICE) service is listening on port $(SERVICE_PORT)." >> ./start_service
	
	# Second, create a debug start script that is not daemonized
	echo '#!/bin/sh' > ./debug_start_service
	echo 'export PERL5LIB=$$PERL5LIB:$(TARGET)/lib' >> ./debug_start_service
	echo 'export KB_DEPLOYMENT_CONFIG=$(KB_DEPLOYMENT_CONFIG)' >> ./debug_start_service
	echo 'export KB_SERVICE_NAME=$(SERVICE_CONFIG_NAME)' >> ./debug_start_service
	echo 'export STARMAN_DEBUG=1' >> ./debug_start_service
	echo "$(DEPLOY_RUNTIME)/bin/starman --listen :$(SERVICE_PORT) --workers 1 \\" >> ./debug_start_service
	echo "    $(TARGET)/lib/$(SERVICE_PSGI_FILE)" >> ./debug_start_service
	
	# Third create the stop script (should be a better way to do this...)
	echo '#!/bin/sh' > ./stop_service
	echo "echo trying to stop $(SERVICE) service." >> ./stop_service
	echo "pid_file=$(PID_FILE)" >> ./stop_service
	echo "if [ ! -f \$$pid_file ] ; then " >> ./stop_service
	echo "	echo \"No pid file: \$$pid_file found for service $(SERVICE).\"" >> ./stop_service
	echo "	exit 1" >> ./stop_service
	echo "fi" >> ./stop_service
	echo "pid=\$$(cat \$$pid_file)" >> ./stop_service
	echo "kill \$$pid" >> ./stop_service
	
	# Finally create a script to reboot the service by stopping, redeploying the service, and starting again
	echo '#!/bin/sh' > ./reboot_service
	echo '# auto-generated script to stop the service, redeploy service implementation, and start the servce' >> ./reboot_service
	echo "./stop_service" >> ./reboot_service
	echo "cd $(ROOT_DEV_MODULE_DIR)" >> ./reboot_service
	echo "make deploy-service-libs" >> ./reboot_service
	echo "cd -" >> ./reboot_service
	echo "./start_service" >> ./reboot_service
	
	# Actually run the deployment of these scripts
	chmod +x start_service stop_service reboot_service debug_start_service
	mkdir -p $(SERVICE_DIR)
	mkdir -p $(SERVICE_DIR)/log
	cp start_service $(SERVICE_DIR)/
	cp debug_start_service $(SERVICE_DIR)/
	cp stop_service $(SERVICE_DIR)/
	cp reboot_service $(SERVICE_DIR)/
