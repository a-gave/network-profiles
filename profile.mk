include $(TOPDIR)/rules.mk

PROFILE_NAME=$(notdir ${CURDIR})
PROFILE_COMMUNITY=$(lastword $(filter-out $(PROFILE_NAME),$(subst /, ,$(CURDIR))))

PKG_NAME:=profile-$(PROFILE_COMMUNITY)-$(PROFILE_NAME)
PKG_MAINTAINER?=$(PROFILE_MAINTAINER)

# from https://github.com/openwrt/luci/blob/master/luci.mk
GIT_COMMIT_DATE:=$(shell git log -n 1 --pretty=%ad --date=short . | sed 's|-|.|g')
GIT_COMMIT_TSTAMP:=$(shell git log -n 1 --pretty=%at . )

PKG_SRC_VERSION:=$(GIT_COMMIT_DATE)~$(GIT_COMMIT_TSTAMP)
PKG_VERSION:=$(if $(PKG_VERSION),$(PKG_VERSION),$(PKG_SRC_VERSION))

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=lime
  SUBMENU:=network-profile
  CATEGORY:=LibreMesh
  TITLE:=$(if $(PROFILE_TITLE),$(PROFILE_TITLE),Profile $(PROFILE_COMMUNITY) $(PROFILE_NAME))
  DEPENDS:=+lime-system $(PROFILE_DEPENDS)
  VERSION:=$(PKG_VERSION)
  PKGARCH:=all
  URL:=https://github.com/libremesh/network-profiles/
endef

ifneq ($(PROFILE_DESCRIPTION),)
 define Package/$(PKG_NAME)/description
   $(strip $(PROFILE_DESCRIPTION))
 endef
endif

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/
	# check if root/ directory exists before copying
	if [ -e ./root/* ]; then $(CP) -r ./root/* $(1)/; fi
endef

define Build/Compile

endef

define Build/Configure
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
