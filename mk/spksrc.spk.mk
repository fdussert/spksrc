# Constants
SHELL := $(SHELL) -e
default: all

include ../../mk/spksrc.directories.mk

# Configure the included makefiles
NAME = $(SPK_NAME)

ifneq ($(ARCH),)
ARCH_SUFFIX = -$(ARCH)
TC = syno$(ARCH_SUFFIX)
endif

SPK_FILE_NAME = $(PACKAGES_DIR)/$(SPK_NAME)$(ARCH_SUFFIX)-$(SPK_VERS)-$(SPK_REV).spk

#####

# Even though this makefile doesn't cross compile, we need this to setup the cross environment.
include ../../mk/spksrc.cross-env.mk
MSG = echo "===>   "

include ../../mk/spksrc.depend.mk

copy: depend
include ../../mk/spksrc.copy.mk

strip: copy
include ../../mk/spksrc.strip.mk


### Packaging rules
$(WORK_DIR)/package.tgz: strip
	$(create_target_dir)
	@[ -f $@ ] && rm $@ || true
	(cd $(STAGING_DIR) && tar cpzf $@ *)

$(WORK_DIR)/INFO: Makefile
	$(create_target_dir)
	@$(MSG) "Creating INFO file for $(SPK_NAME)"
	@echo package=\"$(SPK_NAME)\"  > $@
	@echo version=\"$(SPK_VERS)-$(SPK_REV)\" >> $@
	@echo description=\"$(COMMENT)\" >> $@
	@echo maintainer=\"$(MAINTAINER)\" >> $@
ifneq ($(strip $(ARCH)),)
	@echo arch=\"$(ARCH)\" >> $@
else
	@echo arch=\"noarch\" >> $@
endif
	@echo reloadui=\"$(RELOAD_UI)\" >> $@
	@echo displayname=\"$(DISPLAY_NAME)\" >> $@
ifneq ($(strip $(ADMIN_PORT)),)
	@echo adminport=$(ADMIN_PORT) >> $@
endif
ifneq ($(strip $(SPK_ICON)),)
	@echo package_icon=\"`convert $(SPK_ICON) -thumbnail 72x72 -transparent white - | base64 -w0 -`\" >> $@
endif

DSM_SCRIPTS_DIR = $(WORK_DIR)/scripts

# Generated scripts
DSM_SCRIPTS_  = preinst postinst
DSM_SCRIPTS_ += preuninst postuninst
DSM_SCRIPTS_ += preupgrade postupgrade
# SPK specific scripts
DSM_SCRIPTS_ += start-stop-status
DSM_SCRIPTS_ += installer
DSM_SCRIPTS_ += $(notdir $(basename $(ADDITIONAL_SCRIPTS)))

DSM_SCRIPTS = $(addprefix $(DSM_SCRIPTS_DIR)/,$(DSM_SCRIPTS_))

define dsm_script_redirect
$(create_target_dir)
echo Creating $@
echo '#!/bin/sh' > $@
echo 'PATH=/bin:/usr/bin' >> $@
echo '. `dirname $$0`/installer' >> $@
echo '`basename $$0` > $$SYNOPKG_TEMP_LOGFILE' >> $@
chmod 755 $@
endef

define dsm_script
$(create_target_dir)
echo Creating $@
echo '#!/bin/sh' > $@
echo 'PATH=/bin:/usr/bin' >> $@
echo '. `dirname $$0`/installer' >> $@
echo '`basename $$0`' >> $@
chmod 755 $@
endef

define dsm_script_copy
$(create_target_dir)
echo Creating $@
cp $< $@
chmod 755 $@
endef

$(DSM_SCRIPTS_DIR)/preinst:
	@$(dsm_script_redirect)
$(DSM_SCRIPTS_DIR)/postinst:
	@$(dsm_script_redirect)
$(DSM_SCRIPTS_DIR)/preuninst:
	@$(dsm_script)
$(DSM_SCRIPTS_DIR)/postuninst:
	@$(dsm_script)
$(DSM_SCRIPTS_DIR)/preupgrade:
	@$(dsm_script_redirect)
$(DSM_SCRIPTS_DIR)/postupgrade:
	@$(dsm_script_redirect)

$(DSM_SCRIPTS_DIR)/start-stop-status: $(SSS_SCRIPT) 
	@$(dsm_script_copy)
$(DSM_SCRIPTS_DIR)/installer: $(INSTALLER_SCRIPT) 
	@$(dsm_script_copy)
$(DSM_SCRIPTS_DIR)/%: $(filter %.sh,$(ADDITIONAL_SCRIPTS)) 
	@$(dsm_script_copy)


$(SPK_FILE_NAME): $(WORK_DIR)/package.tgz $(WORK_DIR)/INFO $(DSM_SCRIPTS)
	$(create_target_dir)
	(cd $(WORK_DIR) && tar cpf $@ package.tgz INFO scripts)

package: $(SPK_FILE_NAME)


### Clean rules
clean:
	rm -fr work work-*

all: package


SUPPORTED_TCS = $(notdir $(wildcard ../../toolchains/syno-*))
SUPPORTED_ARCHS = $(notdir $(subst -,/,$(SUPPORTED_TCS)))

.PHONY: all-archs
all-archs: $(addprefix arch-,$(SUPPORTED_ARCHS))

arch-%:
	@$(MSG) Building package for arch $(subst arch-,,$@) 
	@env $(MAKE) ARCH=$(subst arch-,,$@)
	