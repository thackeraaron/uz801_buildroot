# rmtfs

RMTFS_VERSION = v1.3
RMTFS_SITE = https://github.com/linux-msm/rmtfs
RMTFS_SITE_METHOD = git
RMTFS_LICENSE = BSD-3-Clause
RMTFS_LICENSE_FILES = LICENSE
RMTFS_DEPENDENCIES = libqrtr eudev

define RMTFS_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lqrtr -ludev" -C $(@D)
endef

define RMTFS_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/rmtfs $(TARGET_DIR)/usr/sbin/rmtfs
endef

$(eval $(generic-package))
