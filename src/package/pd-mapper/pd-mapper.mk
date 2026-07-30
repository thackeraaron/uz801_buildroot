# pd-mapper

PD_MAPPER_VERSION = v1.1
PD_MAPPER_SITE = https://github.com/linux-msm/pd-mapper
PD_MAPPER_SITE_METHOD = git
PD_MAPPER_LICENSE = BSD-3-Clause
PD_MAPPER_LICENSE_FILES = LICENSE
PD_MAPPER_DEPENDENCIES = libqrtr xz

define PD_MAPPER_BUILD_CMDS
	$(MAKE) CC="$(TARGET_CC)" CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) -lqrtr -llzma" -C $(@D)
endef

define PD_MAPPER_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/pd-mapper $(TARGET_DIR)/usr/sbin/pd-mapper
endef

$(eval $(generic-package))
