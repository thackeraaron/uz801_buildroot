# gt (gadget-tool)
GT_VERSION = 8ebbf3eb6fb77a53d6ace0eebf4f5debb779b576
GT_SITE = $(call github,linux-usb-gadgets,gt,$(GT_VERSION))
GT_LICENSE = Apache-2.0
GT_LICENSE_FILES = LICENSE
GT_DEPENDENCIES = libusbgx
GT_SUBDIR = source

GT_CONF_OPTS = \
	-DWITH_GADGETD=OFF \
	-DWITH_DOCS=OFF \
	-DCMAKE_POLICY_VERSION_MINIMUM=3.5

$(eval $(cmake-package))
