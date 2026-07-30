# libqrtr

LIBQRTR_VERSION = v1.2
LIBQRTR_SITE = https://github.com/linux-msm/qrtr
LIBQRTR_SITE_METHOD = git
LIBQRTR_LICENSE = BSD-3-Clause
LIBQRTR_LICENSE_FILES = LICENSE
LIBQRTR_INSTALL_STAGING = YES

$(eval $(meson-package))
