UNAME := $(shell uname -s)

all:
	# TODO: add a build-in Swiftformat that only works on macOS.
ifeq ($(UNAME), Darwin)
	# ./Pods/SwiftFormat/CommandLineTool/swiftformat \
	# 	Sources \
	# 	Tests \
	# 	--swiftversion 5.0.1 \
	# 	--wraparguments before-first \
	# 	--wrapcollections before-first \
	# 	--importgrouping testable-bottom
endif
	# --exclude "${SRCROOT}/Pods" 
	# mkdir -p output
	# TODO: -q doesn't work with Swift 5.9 / swift test --quiet
	swift test | grep -e ' error: -\[' -e 'DEBUG '