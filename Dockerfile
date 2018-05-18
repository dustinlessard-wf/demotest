FROM drydock-prod.workiva.net/workiva/smithy-runner-generator:179735 as build

# Build Environment Vars
ARG BUILD_ID
ARG BUILD_NUMBER
ARG BUILD_URL
ARG GIT_BRANCH
ARG GIT_COMMIT
ARG GIT_COMMIT_RANGE
ARG GIT_HEAD_URL
ARG GIT_SSH_KEY
ARG GIT_TAG
ARG GIT_MERGE_HEAD
ARG GIT_MERGE_BRANCH
ARG KNOWN_HOSTS_CONTENT

WORKDIR /build/
ADD . /build/

RUN mkdir /root/.ssh
RUN echo "$KNOWN_HOSTS_CONTENT" > "/root/.ssh/known_hosts"
RUN echo "$GIT_SSH_KEY" > "/root/.ssh/id_rsa"
RUN chmod 700 /root/.ssh/
RUN chmod 600 /root/.ssh/id_rsa

ENV CODECOV_TOKEN='bQ4MgjJ0G2Y73v8JNX6L7yMK9679nbYB'
RUN echo "Starting the script sections" && \
        dart --version && \
		pub get && \
		pub run abide && \
#		pub run dart_dev format --check && \
#		pub run dart_dev gen-test-runner --check && \
		pub run dart_dev analyze && \
#		xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev test && \
#		xvfb-run -s '-screen 0 1024x768x24' pub run dart_dev coverage --no-html && \
		pub run dart_dev docs --no-open && \
		cd doc/api && tar -zcvf api.tar.gz * && cd ../.. && \
		tar czvf demotest.pub.tgz LICENSE README.md pubspec.yaml bin/ lib/ && \
		pub run semver_audit report --repo dustinlessard-wf/demotest && \
#		curl https://codecov.workiva.net/bash > ./codecov.sh && \
#		chmod a+x ./codecov.sh && \
#		./codecov.sh -u https://codecov.workiva.net -t $CODECOV_TOKEN -r dustinlessard-wf/demotest -f coverage/coverage.lcov && \
		echo "Script sections completed"
ARG BUILD_ARTIFACTS_DOCUMENTATION=/build/doc/api/api.tar.gz
ARG BUILD_ARTIFACTS_PUB=/build/demotest.pub.tgz
FROM scratch