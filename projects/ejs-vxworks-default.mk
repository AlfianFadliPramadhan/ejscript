#
#   ejs-vxworks-default.mk -- Makefile to build Embedthis Ejscript for vxworks
#

NAME                  := ejs
VERSION               := 2.5.0
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_SQLITE         ?= 1
ME_COM_SSL            ?= 1
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 1

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
LIBS                  += -lgcc

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += $(BUILD)/bin/ejs.out
TARGETS               += $(BUILD)/bin/ejs.db.mapper.mod
TARGETS               += $(BUILD)/bin/ejs.db.sqlite.mod
TARGETS               += $(BUILD)/bin/ejs.mail.mod
TARGETS               += $(BUILD)/bin/ejs.mvc.mod
TARGETS               += $(BUILD)/bin/ejs.tar.mod
TARGETS               += $(BUILD)/bin/ejs.zlib.mod
TARGETS               += $(BUILD)/bin/ca.crt
TARGETS               += $(BUILD)/bin/libejs.db.sqlite.out
TARGETS               += $(BUILD)/bin/libejs.web.out
TARGETS               += $(BUILD)/bin/libejs.zlib.out
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(BUILD)/bin/libest.out
endif
TARGETS               += $(BUILD)/bin/libmprssl.out
TARGETS               += $(BUILD)/bin/ejsman.out

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/ejs-vxworks-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/ejs-vxworks-default-me.h >/dev/null ; then\
		cp projects/ejs-vxworks-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/dtoa.o"
	rm -f "$(BUILD)/obj/ecAst.o"
	rm -f "$(BUILD)/obj/ecCodeGen.o"
	rm -f "$(BUILD)/obj/ecCompiler.o"
	rm -f "$(BUILD)/obj/ecLex.o"
	rm -f "$(BUILD)/obj/ecModuleWrite.o"
	rm -f "$(BUILD)/obj/ecParser.o"
	rm -f "$(BUILD)/obj/ecState.o"
	rm -f "$(BUILD)/obj/ejs.o"
	rm -f "$(BUILD)/obj/ejsApp.o"
	rm -f "$(BUILD)/obj/ejsArray.o"
	rm -f "$(BUILD)/obj/ejsBlock.o"
	rm -f "$(BUILD)/obj/ejsBoolean.o"
	rm -f "$(BUILD)/obj/ejsByteArray.o"
	rm -f "$(BUILD)/obj/ejsByteCode.o"
	rm -f "$(BUILD)/obj/ejsCache.o"
	rm -f "$(BUILD)/obj/ejsCmd.o"
	rm -f "$(BUILD)/obj/ejsConfig.o"
	rm -f "$(BUILD)/obj/ejsDate.o"
	rm -f "$(BUILD)/obj/ejsDebug.o"
	rm -f "$(BUILD)/obj/ejsError.o"
	rm -f "$(BUILD)/obj/ejsException.o"
	rm -f "$(BUILD)/obj/ejsFile.o"
	rm -f "$(BUILD)/obj/ejsFileSystem.o"
	rm -f "$(BUILD)/obj/ejsFrame.o"
	rm -f "$(BUILD)/obj/ejsFunction.o"
	rm -f "$(BUILD)/obj/ejsGC.o"
	rm -f "$(BUILD)/obj/ejsGlobal.o"
	rm -f "$(BUILD)/obj/ejsHelper.o"
	rm -f "$(BUILD)/obj/ejsHttp.o"
	rm -f "$(BUILD)/obj/ejsHttpServer.o"
	rm -f "$(BUILD)/obj/ejsInterp.o"
	rm -f "$(BUILD)/obj/ejsIterator.o"
	rm -f "$(BUILD)/obj/ejsJSON.o"
	rm -f "$(BUILD)/obj/ejsLoader.o"
	rm -f "$(BUILD)/obj/ejsLocalCache.o"
	rm -f "$(BUILD)/obj/ejsMath.o"
	rm -f "$(BUILD)/obj/ejsMemory.o"
	rm -f "$(BUILD)/obj/ejsModule.o"
	rm -f "$(BUILD)/obj/ejsMprLog.o"
	rm -f "$(BUILD)/obj/ejsNamespace.o"
	rm -f "$(BUILD)/obj/ejsNull.o"
	rm -f "$(BUILD)/obj/ejsNumber.o"
	rm -f "$(BUILD)/obj/ejsObject.o"
	rm -f "$(BUILD)/obj/ejsPath.o"
	rm -f "$(BUILD)/obj/ejsPot.o"
	rm -f "$(BUILD)/obj/ejsRegExp.o"
	rm -f "$(BUILD)/obj/ejsRequest.o"
	rm -f "$(BUILD)/obj/ejsScope.o"
	rm -f "$(BUILD)/obj/ejsService.o"
	rm -f "$(BUILD)/obj/ejsSession.o"
	rm -f "$(BUILD)/obj/ejsSocket.o"
	rm -f "$(BUILD)/obj/ejsSqlite.o"
	rm -f "$(BUILD)/obj/ejsString.o"
	rm -f "$(BUILD)/obj/ejsSystem.o"
	rm -f "$(BUILD)/obj/ejsTimer.o"
	rm -f "$(BUILD)/obj/ejsType.o"
	rm -f "$(BUILD)/obj/ejsUri.o"
	rm -f "$(BUILD)/obj/ejsVoid.o"
	rm -f "$(BUILD)/obj/ejsWeb.o"
	rm -f "$(BUILD)/obj/ejsWebSocket.o"
	rm -f "$(BUILD)/obj/ejsWorker.o"
	rm -f "$(BUILD)/obj/ejsXML.o"
	rm -f "$(BUILD)/obj/ejsXMLList.o"
	rm -f "$(BUILD)/obj/ejsXMLLoader.o"
	rm -f "$(BUILD)/obj/ejsZlib.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/ejs.out"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/libejs.out"
	rm -f "$(BUILD)/bin/libejs.db.sqlite.out"
	rm -f "$(BUILD)/bin/libejs.web.out"
	rm -f "$(BUILD)/bin/libejs.zlib.out"
	rm -f "$(BUILD)/bin/libest.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmpr.out"
	rm -f "$(BUILD)/bin/libmprssl.out"
	rm -f "$(BUILD)/bin/libpcre.out"
	rm -f "$(BUILD)/bin/libsql.out"
	rm -f "$(BUILD)/bin/libzlib.out"
	rm -f "$(BUILD)/bin/ejsman.out"

clobber: clean
	rm -fr ./$(BUILD)


#
#   ejs.cache.local.slots.h
#
DEPS_1 += src/slots/ejs.cache.local.slots.h

$(BUILD)/inc/ejs.cache.local.slots.h: $(DEPS_1)
	@echo '      [Copy] $(BUILD)/inc/ejs.cache.local.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/slots/ejs.cache.local.slots.h $(BUILD)/inc/ejs.cache.local.slots.h

#
#   ejs.db.sqlite.slots.h
#
DEPS_2 += src/slots/ejs.db.sqlite.slots.h

$(BUILD)/inc/ejs.db.sqlite.slots.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/ejs.db.sqlite.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/slots/ejs.db.sqlite.slots.h $(BUILD)/inc/ejs.db.sqlite.slots.h

#
#   me.h
#
$(BUILD)/inc/me.h: $(DEPS_3)

#
#   osdep.h
#
DEPS_4 += src/paks/osdep/osdep.h
DEPS_4 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_5 += src/paks/mpr/mpr.h
DEPS_5 += $(BUILD)/inc/me.h
DEPS_5 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_6 += src/paks/http/http.h
DEPS_6 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/http/http.h $(BUILD)/inc/http.h

#
#   ejsByteCode.h
#
src/ejsByteCode.h: $(DEPS_7)

#
#   ejsByteCodeTable.h
#
src/ejsByteCodeTable.h: $(DEPS_8)

#
#   ejs.slots.h
#
DEPS_9 += src/slots/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/slots/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   ejsCustomize.h
#
src/ejsCustomize.h: $(DEPS_10)

#
#   ejs.h
#
DEPS_11 += src/ejs.h
DEPS_11 += $(BUILD)/inc/mpr.h
DEPS_11 += $(BUILD)/inc/http.h
DEPS_11 += src/ejsByteCode.h
DEPS_11 += src/ejsByteCodeTable.h
DEPS_11 += $(BUILD)/inc/ejs.slots.h
DEPS_11 += src/ejsCustomize.h

$(BUILD)/inc/ejs.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs.h $(BUILD)/inc/ejs.h

#
#   ejs.web.slots.h
#
DEPS_12 += src/slots/ejs.web.slots.h

$(BUILD)/inc/ejs.web.slots.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/ejs.web.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/slots/ejs.web.slots.h $(BUILD)/inc/ejs.web.slots.h

#
#   ejs.zlib.slots.h
#
DEPS_13 += src/slots/ejs.zlib.slots.h

$(BUILD)/inc/ejs.zlib.slots.h: $(DEPS_13)
	@echo '      [Copy] $(BUILD)/inc/ejs.zlib.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/slots/ejs.zlib.slots.h $(BUILD)/inc/ejs.zlib.slots.h

#
#   ejsByteCode.h
#
DEPS_14 += src/ejsByteCode.h

$(BUILD)/inc/ejsByteCode.h: $(DEPS_14)
	@echo '      [Copy] $(BUILD)/inc/ejsByteCode.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejsByteCode.h $(BUILD)/inc/ejsByteCode.h

#
#   ejsByteCodeTable.h
#
DEPS_15 += src/ejsByteCodeTable.h

$(BUILD)/inc/ejsByteCodeTable.h: $(DEPS_15)
	@echo '      [Copy] $(BUILD)/inc/ejsByteCodeTable.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejsByteCodeTable.h $(BUILD)/inc/ejsByteCodeTable.h

#
#   ejs.h
#
src/ejs.h: $(DEPS_16)

#
#   ejsCompiler.h
#
DEPS_17 += src/ejsCompiler.h
DEPS_17 += src/ejs.h

$(BUILD)/inc/ejsCompiler.h: $(DEPS_17)
	@echo '      [Copy] $(BUILD)/inc/ejsCompiler.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejsCompiler.h $(BUILD)/inc/ejsCompiler.h

#
#   ejsCustomize.h
#
DEPS_18 += src/ejsCustomize.h

$(BUILD)/inc/ejsCustomize.h: $(DEPS_18)
	@echo '      [Copy] $(BUILD)/inc/ejsCustomize.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejsCustomize.h $(BUILD)/inc/ejsCustomize.h

#
#   ejsWeb.h
#
DEPS_19 += src/ejs.web/ejsWeb.h

$(BUILD)/inc/ejsWeb.h: $(DEPS_19)
	@echo '      [Copy] $(BUILD)/inc/ejsWeb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs.web/ejsWeb.h $(BUILD)/inc/ejsWeb.h

#
#   est.h
#
DEPS_20 += src/paks/est/est.h

$(BUILD)/inc/est.h: $(DEPS_20)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/est/est.h $(BUILD)/inc/est.h

#
#   pcre.h
#
DEPS_21 += src/paks/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_21)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_22 += src/paks/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_22)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_23 += src/paks/zlib/zlib.h
DEPS_23 += $(BUILD)/inc/me.h

$(BUILD)/inc/zlib.h: $(DEPS_23)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   dtoa.o
#
DEPS_24 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/dtoa.o: \
    src/core/src/dtoa.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/dtoa.o'
	$(CC) -c -o $(BUILD)/obj/dtoa.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/dtoa.c

#
#   ejsCompiler.h
#
src/ejsCompiler.h: $(DEPS_25)

#
#   ecAst.o
#
DEPS_26 += src/ejsCompiler.h

$(BUILD)/obj/ecAst.o: \
    src/compiler/ecAst.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/ecAst.o'
	$(CC) -c -o $(BUILD)/obj/ecAst.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecAst.c

#
#   ecCodeGen.o
#
DEPS_27 += src/ejsCompiler.h

$(BUILD)/obj/ecCodeGen.o: \
    src/compiler/ecCodeGen.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/ecCodeGen.o'
	$(CC) -c -o $(BUILD)/obj/ecCodeGen.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecCodeGen.c

#
#   ecCompiler.o
#
DEPS_28 += src/ejsCompiler.h

$(BUILD)/obj/ecCompiler.o: \
    src/compiler/ecCompiler.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/ecCompiler.o'
	$(CC) -c -o $(BUILD)/obj/ecCompiler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecCompiler.c

#
#   ecLex.o
#
DEPS_29 += src/ejsCompiler.h

$(BUILD)/obj/ecLex.o: \
    src/compiler/ecLex.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/ecLex.o'
	$(CC) -c -o $(BUILD)/obj/ecLex.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecLex.c

#
#   ecModuleWrite.o
#
DEPS_30 += src/ejsCompiler.h

$(BUILD)/obj/ecModuleWrite.o: \
    src/compiler/ecModuleWrite.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/ecModuleWrite.o'
	$(CC) -c -o $(BUILD)/obj/ecModuleWrite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecModuleWrite.c

#
#   ecParser.o
#
DEPS_31 += src/ejsCompiler.h

$(BUILD)/obj/ecParser.o: \
    src/compiler/ecParser.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/ecParser.o'
	$(CC) -c -o $(BUILD)/obj/ecParser.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecParser.c

#
#   ecState.o
#
DEPS_32 += src/ejsCompiler.h

$(BUILD)/obj/ecState.o: \
    src/compiler/ecState.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/ecState.o'
	$(CC) -c -o $(BUILD)/obj/ecState.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/compiler/ecState.c

#
#   ejs.o
#
DEPS_33 += $(BUILD)/inc/me.h
DEPS_33 += $(BUILD)/inc/ejsCompiler.h

$(BUILD)/obj/ejs.o: \
    src/cmd/ejs.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c -o $(BUILD)/obj/ejs.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/cmd/ejs.c

#
#   ejsApp.o
#
DEPS_34 += src/ejs.h

$(BUILD)/obj/ejsApp.o: \
    src/core/src/ejsApp.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/ejsApp.o'
	$(CC) -c -o $(BUILD)/obj/ejsApp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsApp.c

#
#   ejsArray.o
#
DEPS_35 += src/ejs.h

$(BUILD)/obj/ejsArray.o: \
    src/core/src/ejsArray.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/ejsArray.o'
	$(CC) -c -o $(BUILD)/obj/ejsArray.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsArray.c

#
#   ejsBlock.o
#
DEPS_36 += src/ejs.h

$(BUILD)/obj/ejsBlock.o: \
    src/core/src/ejsBlock.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/ejsBlock.o'
	$(CC) -c -o $(BUILD)/obj/ejsBlock.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsBlock.c

#
#   ejsBoolean.o
#
DEPS_37 += src/ejs.h

$(BUILD)/obj/ejsBoolean.o: \
    src/core/src/ejsBoolean.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/ejsBoolean.o'
	$(CC) -c -o $(BUILD)/obj/ejsBoolean.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsBoolean.c

#
#   ejsByteArray.o
#
DEPS_38 += src/ejs.h

$(BUILD)/obj/ejsByteArray.o: \
    src/core/src/ejsByteArray.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/ejsByteArray.o'
	$(CC) -c -o $(BUILD)/obj/ejsByteArray.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsByteArray.c

#
#   ejsByteCode.o
#
DEPS_39 += src/ejs.h

$(BUILD)/obj/ejsByteCode.o: \
    src/vm/ejsByteCode.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/ejsByteCode.o'
	$(CC) -c -o $(BUILD)/obj/ejsByteCode.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsByteCode.c

#
#   ejsCache.o
#
DEPS_40 += src/ejs.h

$(BUILD)/obj/ejsCache.o: \
    src/core/src/ejsCache.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/ejsCache.o'
	$(CC) -c -o $(BUILD)/obj/ejsCache.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsCache.c

#
#   ejsCmd.o
#
DEPS_41 += src/ejs.h

$(BUILD)/obj/ejsCmd.o: \
    src/core/src/ejsCmd.c $(DEPS_41)
	@echo '   [Compile] $(BUILD)/obj/ejsCmd.o'
	$(CC) -c -o $(BUILD)/obj/ejsCmd.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsCmd.c

#
#   ejsConfig.o
#
DEPS_42 += src/ejs.h

$(BUILD)/obj/ejsConfig.o: \
    src/core/src/ejsConfig.c $(DEPS_42)
	@echo '   [Compile] $(BUILD)/obj/ejsConfig.o'
	$(CC) -c -o $(BUILD)/obj/ejsConfig.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsConfig.c

#
#   ejsDate.o
#
DEPS_43 += src/ejs.h

$(BUILD)/obj/ejsDate.o: \
    src/core/src/ejsDate.c $(DEPS_43)
	@echo '   [Compile] $(BUILD)/obj/ejsDate.o'
	$(CC) -c -o $(BUILD)/obj/ejsDate.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsDate.c

#
#   ejsDebug.o
#
DEPS_44 += src/ejs.h

$(BUILD)/obj/ejsDebug.o: \
    src/core/src/ejsDebug.c $(DEPS_44)
	@echo '   [Compile] $(BUILD)/obj/ejsDebug.o'
	$(CC) -c -o $(BUILD)/obj/ejsDebug.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsDebug.c

#
#   ejsError.o
#
DEPS_45 += src/ejs.h

$(BUILD)/obj/ejsError.o: \
    src/core/src/ejsError.c $(DEPS_45)
	@echo '   [Compile] $(BUILD)/obj/ejsError.o'
	$(CC) -c -o $(BUILD)/obj/ejsError.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsError.c

#
#   ejsException.o
#
DEPS_46 += src/ejs.h

$(BUILD)/obj/ejsException.o: \
    src/vm/ejsException.c $(DEPS_46)
	@echo '   [Compile] $(BUILD)/obj/ejsException.o'
	$(CC) -c -o $(BUILD)/obj/ejsException.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsException.c

#
#   ejsFile.o
#
DEPS_47 += src/ejs.h

$(BUILD)/obj/ejsFile.o: \
    src/core/src/ejsFile.c $(DEPS_47)
	@echo '   [Compile] $(BUILD)/obj/ejsFile.o'
	$(CC) -c -o $(BUILD)/obj/ejsFile.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsFile.c

#
#   ejsFileSystem.o
#
DEPS_48 += src/ejs.h

$(BUILD)/obj/ejsFileSystem.o: \
    src/core/src/ejsFileSystem.c $(DEPS_48)
	@echo '   [Compile] $(BUILD)/obj/ejsFileSystem.o'
	$(CC) -c -o $(BUILD)/obj/ejsFileSystem.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsFileSystem.c

#
#   ejsFrame.o
#
DEPS_49 += src/ejs.h

$(BUILD)/obj/ejsFrame.o: \
    src/core/src/ejsFrame.c $(DEPS_49)
	@echo '   [Compile] $(BUILD)/obj/ejsFrame.o'
	$(CC) -c -o $(BUILD)/obj/ejsFrame.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsFrame.c

#
#   ejsFunction.o
#
DEPS_50 += src/ejs.h

$(BUILD)/obj/ejsFunction.o: \
    src/core/src/ejsFunction.c $(DEPS_50)
	@echo '   [Compile] $(BUILD)/obj/ejsFunction.o'
	$(CC) -c -o $(BUILD)/obj/ejsFunction.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsFunction.c

#
#   ejsGC.o
#
DEPS_51 += src/ejs.h

$(BUILD)/obj/ejsGC.o: \
    src/core/src/ejsGC.c $(DEPS_51)
	@echo '   [Compile] $(BUILD)/obj/ejsGC.o'
	$(CC) -c -o $(BUILD)/obj/ejsGC.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsGC.c

#
#   ejsGlobal.o
#
DEPS_52 += src/ejs.h

$(BUILD)/obj/ejsGlobal.o: \
    src/core/src/ejsGlobal.c $(DEPS_52)
	@echo '   [Compile] $(BUILD)/obj/ejsGlobal.o'
	$(CC) -c -o $(BUILD)/obj/ejsGlobal.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsGlobal.c

#
#   ejsHelper.o
#
DEPS_53 += src/ejs.h

$(BUILD)/obj/ejsHelper.o: \
    src/vm/ejsHelper.c $(DEPS_53)
	@echo '   [Compile] $(BUILD)/obj/ejsHelper.o'
	$(CC) -c -o $(BUILD)/obj/ejsHelper.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsHelper.c

#
#   ejsHttp.o
#
DEPS_54 += src/ejs.h

$(BUILD)/obj/ejsHttp.o: \
    src/core/src/ejsHttp.c $(DEPS_54)
	@echo '   [Compile] $(BUILD)/obj/ejsHttp.o'
	$(CC) -c -o $(BUILD)/obj/ejsHttp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsHttp.c

#
#   ejsWeb.h
#
src/ejs.web/ejsWeb.h: $(DEPS_55)

#
#   ejsHttpServer.o
#
DEPS_56 += $(BUILD)/inc/me.h
DEPS_56 += $(BUILD)/inc/ejs.h
DEPS_56 += $(BUILD)/inc/ejsCompiler.h
DEPS_56 += src/ejs.web/ejsWeb.h
DEPS_56 += $(BUILD)/inc/ejs.web.slots.h

$(BUILD)/obj/ejsHttpServer.o: \
    src/ejs.web/ejsHttpServer.c $(DEPS_56)
	@echo '   [Compile] $(BUILD)/obj/ejsHttpServer.o'
	$(CC) -c -o $(BUILD)/obj/ejsHttpServer.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.web/ejsHttpServer.c

#
#   ejsInterp.o
#
DEPS_57 += src/ejs.h

$(BUILD)/obj/ejsInterp.o: \
    src/vm/ejsInterp.c $(DEPS_57)
	@echo '   [Compile] $(BUILD)/obj/ejsInterp.o'
	$(CC) -c -o $(BUILD)/obj/ejsInterp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsInterp.c

#
#   ejsIterator.o
#
DEPS_58 += src/ejs.h

$(BUILD)/obj/ejsIterator.o: \
    src/core/src/ejsIterator.c $(DEPS_58)
	@echo '   [Compile] $(BUILD)/obj/ejsIterator.o'
	$(CC) -c -o $(BUILD)/obj/ejsIterator.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsIterator.c

#
#   ejsJSON.o
#
DEPS_59 += src/ejs.h

$(BUILD)/obj/ejsJSON.o: \
    src/core/src/ejsJSON.c $(DEPS_59)
	@echo '   [Compile] $(BUILD)/obj/ejsJSON.o'
	$(CC) -c -o $(BUILD)/obj/ejsJSON.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsJSON.c

#
#   ejsLoader.o
#
DEPS_60 += src/ejs.h

$(BUILD)/obj/ejsLoader.o: \
    src/vm/ejsLoader.c $(DEPS_60)
	@echo '   [Compile] $(BUILD)/obj/ejsLoader.o'
	$(CC) -c -o $(BUILD)/obj/ejsLoader.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsLoader.c

#
#   ejsLocalCache.o
#
DEPS_61 += src/ejs.h

$(BUILD)/obj/ejsLocalCache.o: \
    src/core/src/ejsLocalCache.c $(DEPS_61)
	@echo '   [Compile] $(BUILD)/obj/ejsLocalCache.o'
	$(CC) -c -o $(BUILD)/obj/ejsLocalCache.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsLocalCache.c

#
#   ejsMath.o
#
DEPS_62 += src/ejs.h

$(BUILD)/obj/ejsMath.o: \
    src/core/src/ejsMath.c $(DEPS_62)
	@echo '   [Compile] $(BUILD)/obj/ejsMath.o'
	$(CC) -c -o $(BUILD)/obj/ejsMath.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsMath.c

#
#   ejsMemory.o
#
DEPS_63 += src/ejs.h

$(BUILD)/obj/ejsMemory.o: \
    src/core/src/ejsMemory.c $(DEPS_63)
	@echo '   [Compile] $(BUILD)/obj/ejsMemory.o'
	$(CC) -c -o $(BUILD)/obj/ejsMemory.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsMemory.c

#
#   ejsModule.o
#
DEPS_64 += src/ejs.h

$(BUILD)/obj/ejsModule.o: \
    src/vm/ejsModule.c $(DEPS_64)
	@echo '   [Compile] $(BUILD)/obj/ejsModule.o'
	$(CC) -c -o $(BUILD)/obj/ejsModule.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsModule.c

#
#   ejsMprLog.o
#
DEPS_65 += src/ejs.h

$(BUILD)/obj/ejsMprLog.o: \
    src/core/src/ejsMprLog.c $(DEPS_65)
	@echo '   [Compile] $(BUILD)/obj/ejsMprLog.o'
	$(CC) -c -o $(BUILD)/obj/ejsMprLog.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsMprLog.c

#
#   ejsNamespace.o
#
DEPS_66 += src/ejs.h

$(BUILD)/obj/ejsNamespace.o: \
    src/core/src/ejsNamespace.c $(DEPS_66)
	@echo '   [Compile] $(BUILD)/obj/ejsNamespace.o'
	$(CC) -c -o $(BUILD)/obj/ejsNamespace.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsNamespace.c

#
#   ejsNull.o
#
DEPS_67 += src/ejs.h

$(BUILD)/obj/ejsNull.o: \
    src/core/src/ejsNull.c $(DEPS_67)
	@echo '   [Compile] $(BUILD)/obj/ejsNull.o'
	$(CC) -c -o $(BUILD)/obj/ejsNull.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsNull.c

#
#   ejsNumber.o
#
DEPS_68 += src/ejs.h

$(BUILD)/obj/ejsNumber.o: \
    src/core/src/ejsNumber.c $(DEPS_68)
	@echo '   [Compile] $(BUILD)/obj/ejsNumber.o'
	$(CC) -c -o $(BUILD)/obj/ejsNumber.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsNumber.c

#
#   ejsObject.o
#
DEPS_69 += src/ejs.h

$(BUILD)/obj/ejsObject.o: \
    src/core/src/ejsObject.c $(DEPS_69)
	@echo '   [Compile] $(BUILD)/obj/ejsObject.o'
	$(CC) -c -o $(BUILD)/obj/ejsObject.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsObject.c

#
#   ejsPath.o
#
DEPS_70 += src/ejs.h
DEPS_70 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/ejsPath.o: \
    src/core/src/ejsPath.c $(DEPS_70)
	@echo '   [Compile] $(BUILD)/obj/ejsPath.o'
	$(CC) -c -o $(BUILD)/obj/ejsPath.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsPath.c

#
#   ejsPot.o
#
DEPS_71 += src/ejs.h

$(BUILD)/obj/ejsPot.o: \
    src/core/src/ejsPot.c $(DEPS_71)
	@echo '   [Compile] $(BUILD)/obj/ejsPot.o'
	$(CC) -c -o $(BUILD)/obj/ejsPot.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsPot.c

#
#   ejsRegExp.o
#
DEPS_72 += src/ejs.h
DEPS_72 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/ejsRegExp.o: \
    src/core/src/ejsRegExp.c $(DEPS_72)
	@echo '   [Compile] $(BUILD)/obj/ejsRegExp.o'
	$(CC) -c -o $(BUILD)/obj/ejsRegExp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsRegExp.c

#
#   ejsRequest.o
#
DEPS_73 += $(BUILD)/inc/me.h
DEPS_73 += $(BUILD)/inc/ejs.h
DEPS_73 += $(BUILD)/inc/ejsCompiler.h
DEPS_73 += src/ejs.web/ejsWeb.h
DEPS_73 += $(BUILD)/inc/ejs.web.slots.h

$(BUILD)/obj/ejsRequest.o: \
    src/ejs.web/ejsRequest.c $(DEPS_73)
	@echo '   [Compile] $(BUILD)/obj/ejsRequest.o'
	$(CC) -c -o $(BUILD)/obj/ejsRequest.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.web/ejsRequest.c

#
#   ejsScope.o
#
DEPS_74 += src/ejs.h

$(BUILD)/obj/ejsScope.o: \
    src/vm/ejsScope.c $(DEPS_74)
	@echo '   [Compile] $(BUILD)/obj/ejsScope.o'
	$(CC) -c -o $(BUILD)/obj/ejsScope.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsScope.c

#
#   ejsService.o
#
DEPS_75 += src/ejs.h

$(BUILD)/obj/ejsService.o: \
    src/vm/ejsService.c $(DEPS_75)
	@echo '   [Compile] $(BUILD)/obj/ejsService.o'
	$(CC) -c -o $(BUILD)/obj/ejsService.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/vm/ejsService.c

#
#   ejsSession.o
#
DEPS_76 += $(BUILD)/inc/me.h
DEPS_76 += $(BUILD)/inc/ejs.h
DEPS_76 += src/ejs.web/ejsWeb.h

$(BUILD)/obj/ejsSession.o: \
    src/ejs.web/ejsSession.c $(DEPS_76)
	@echo '   [Compile] $(BUILD)/obj/ejsSession.o'
	$(CC) -c -o $(BUILD)/obj/ejsSession.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.web/ejsSession.c

#
#   ejsSocket.o
#
DEPS_77 += src/ejs.h

$(BUILD)/obj/ejsSocket.o: \
    src/core/src/ejsSocket.c $(DEPS_77)
	@echo '   [Compile] $(BUILD)/obj/ejsSocket.o'
	$(CC) -c -o $(BUILD)/obj/ejsSocket.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsSocket.c

#
#   ejsSqlite.o
#
DEPS_78 += $(BUILD)/inc/ejs.h
DEPS_78 += $(BUILD)/inc/ejs.db.sqlite.slots.h

$(BUILD)/obj/ejsSqlite.o: \
    src/ejs.db.sqlite/ejsSqlite.c $(DEPS_78)
	@echo '   [Compile] $(BUILD)/obj/ejsSqlite.o'
	$(CC) -c -o $(BUILD)/obj/ejsSqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.db.sqlite/ejsSqlite.c

#
#   ejsString.o
#
DEPS_79 += src/ejs.h
DEPS_79 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/ejsString.o: \
    src/core/src/ejsString.c $(DEPS_79)
	@echo '   [Compile] $(BUILD)/obj/ejsString.o'
	$(CC) -c -o $(BUILD)/obj/ejsString.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsString.c

#
#   ejsSystem.o
#
DEPS_80 += src/ejs.h

$(BUILD)/obj/ejsSystem.o: \
    src/core/src/ejsSystem.c $(DEPS_80)
	@echo '   [Compile] $(BUILD)/obj/ejsSystem.o'
	$(CC) -c -o $(BUILD)/obj/ejsSystem.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsSystem.c

#
#   ejsTimer.o
#
DEPS_81 += src/ejs.h

$(BUILD)/obj/ejsTimer.o: \
    src/core/src/ejsTimer.c $(DEPS_81)
	@echo '   [Compile] $(BUILD)/obj/ejsTimer.o'
	$(CC) -c -o $(BUILD)/obj/ejsTimer.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsTimer.c

#
#   ejsType.o
#
DEPS_82 += src/ejs.h

$(BUILD)/obj/ejsType.o: \
    src/core/src/ejsType.c $(DEPS_82)
	@echo '   [Compile] $(BUILD)/obj/ejsType.o'
	$(CC) -c -o $(BUILD)/obj/ejsType.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsType.c

#
#   ejsUri.o
#
DEPS_83 += src/ejs.h

$(BUILD)/obj/ejsUri.o: \
    src/core/src/ejsUri.c $(DEPS_83)
	@echo '   [Compile] $(BUILD)/obj/ejsUri.o'
	$(CC) -c -o $(BUILD)/obj/ejsUri.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsUri.c

#
#   ejsVoid.o
#
DEPS_84 += src/ejs.h

$(BUILD)/obj/ejsVoid.o: \
    src/core/src/ejsVoid.c $(DEPS_84)
	@echo '   [Compile] $(BUILD)/obj/ejsVoid.o'
	$(CC) -c -o $(BUILD)/obj/ejsVoid.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsVoid.c

#
#   ejsWeb.o
#
DEPS_85 += $(BUILD)/inc/me.h
DEPS_85 += $(BUILD)/inc/ejs.h
DEPS_85 += $(BUILD)/inc/ejsCompiler.h
DEPS_85 += src/ejs.web/ejsWeb.h
DEPS_85 += $(BUILD)/inc/ejs.web.slots.h

$(BUILD)/obj/ejsWeb.o: \
    src/ejs.web/ejsWeb.c $(DEPS_85)
	@echo '   [Compile] $(BUILD)/obj/ejsWeb.o'
	$(CC) -c -o $(BUILD)/obj/ejsWeb.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.web/ejsWeb.c

#
#   ejsWebSocket.o
#
DEPS_86 += src/ejs.h

$(BUILD)/obj/ejsWebSocket.o: \
    src/core/src/ejsWebSocket.c $(DEPS_86)
	@echo '   [Compile] $(BUILD)/obj/ejsWebSocket.o'
	$(CC) -c -o $(BUILD)/obj/ejsWebSocket.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsWebSocket.c

#
#   ejsWorker.o
#
DEPS_87 += src/ejs.h

$(BUILD)/obj/ejsWorker.o: \
    src/core/src/ejsWorker.c $(DEPS_87)
	@echo '   [Compile] $(BUILD)/obj/ejsWorker.o'
	$(CC) -c -o $(BUILD)/obj/ejsWorker.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsWorker.c

#
#   ejsXML.o
#
DEPS_88 += src/ejs.h

$(BUILD)/obj/ejsXML.o: \
    src/core/src/ejsXML.c $(DEPS_88)
	@echo '   [Compile] $(BUILD)/obj/ejsXML.o'
	$(CC) -c -o $(BUILD)/obj/ejsXML.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsXML.c

#
#   ejsXMLList.o
#
DEPS_89 += src/ejs.h

$(BUILD)/obj/ejsXMLList.o: \
    src/core/src/ejsXMLList.c $(DEPS_89)
	@echo '   [Compile] $(BUILD)/obj/ejsXMLList.o'
	$(CC) -c -o $(BUILD)/obj/ejsXMLList.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsXMLList.c

#
#   ejsXMLLoader.o
#
DEPS_90 += src/ejs.h

$(BUILD)/obj/ejsXMLLoader.o: \
    src/core/src/ejsXMLLoader.c $(DEPS_90)
	@echo '   [Compile] $(BUILD)/obj/ejsXMLLoader.o'
	$(CC) -c -o $(BUILD)/obj/ejsXMLLoader.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/core/src/ejsXMLLoader.c

#
#   ejsZlib.o
#
DEPS_91 += $(BUILD)/inc/ejs.h
DEPS_91 += $(BUILD)/inc/zlib.h
DEPS_91 += $(BUILD)/inc/ejs.zlib.slots.h

$(BUILD)/obj/ejsZlib.o: \
    src/ejs.zlib/ejsZlib.c $(DEPS_91)
	@echo '   [Compile] $(BUILD)/obj/ejsZlib.o'
	$(CC) -c -o $(BUILD)/obj/ejsZlib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/ejs.zlib/ejsZlib.c

#
#   est.h
#
src/paks/est/est.h: $(DEPS_92)

#
#   estLib.o
#
DEPS_93 += src/paks/est/est.h

$(BUILD)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_93)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c -o $(BUILD)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

#
#   http.h
#
src/paks/http/http.h: $(DEPS_94)

#
#   httpLib.o
#
DEPS_95 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_95)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

#
#   mpr.h
#
src/paks/mpr/mpr.h: $(DEPS_96)

#
#   manager.o
#
DEPS_97 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_97)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   mprLib.o
#
DEPS_98 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_98)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_99 += $(BUILD)/inc/me.h
DEPS_99 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_99)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.h
#
src/paks/pcre/pcre.h: $(DEPS_100)

#
#   pcre.o
#
DEPS_101 += $(BUILD)/inc/me.h
DEPS_101 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_101)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

#
#   sqlite3.h
#
src/paks/sqlite/sqlite3.h: $(DEPS_102)

#
#   sqlite3.o
#
DEPS_103 += $(BUILD)/inc/me.h
DEPS_103 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_103)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

#
#   zlib.h
#
src/paks/zlib/zlib.h: $(DEPS_104)

#
#   zlib.o
#
DEPS_105 += $(BUILD)/inc/me.h
DEPS_105 += src/paks/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_105)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/zlib/zlib.c

#
#   slots
#
slots: $(DEPS_106)

#
#   libmpr
#
DEPS_107 += $(BUILD)/inc/mpr.h
DEPS_107 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.out: $(DEPS_107)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	$(CC) -r -o $(BUILD)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_108 += $(BUILD)/inc/pcre.h
DEPS_108 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_108)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	$(CC) -r -o $(BUILD)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_109 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_109 += $(BUILD)/bin/libpcre.out
endif
DEPS_109 += $(BUILD)/inc/http.h
DEPS_109 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.out: $(DEPS_109)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	$(CC) -r -o $(BUILD)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBS) 
endif

#
#   libejs
#
DEPS_110 += slots
ifeq ($(ME_COM_HTTP),1)
    DEPS_110 += $(BUILD)/bin/libhttp.out
endif
DEPS_110 += $(BUILD)/inc/ejs.cache.local.slots.h
DEPS_110 += $(BUILD)/inc/ejs.db.sqlite.slots.h
DEPS_110 += $(BUILD)/inc/ejs.slots.h
DEPS_110 += $(BUILD)/inc/ejs.web.slots.h
DEPS_110 += $(BUILD)/inc/ejs.zlib.slots.h
DEPS_110 += $(BUILD)/inc/ejs.h
DEPS_110 += $(BUILD)/inc/ejsByteCode.h
DEPS_110 += $(BUILD)/inc/ejsByteCodeTable.h
DEPS_110 += $(BUILD)/inc/ejsCompiler.h
DEPS_110 += $(BUILD)/inc/ejsCustomize.h
DEPS_110 += $(BUILD)/obj/ecAst.o
DEPS_110 += $(BUILD)/obj/ecCodeGen.o
DEPS_110 += $(BUILD)/obj/ecCompiler.o
DEPS_110 += $(BUILD)/obj/ecLex.o
DEPS_110 += $(BUILD)/obj/ecModuleWrite.o
DEPS_110 += $(BUILD)/obj/ecParser.o
DEPS_110 += $(BUILD)/obj/ecState.o
DEPS_110 += $(BUILD)/obj/dtoa.o
DEPS_110 += $(BUILD)/obj/ejsApp.o
DEPS_110 += $(BUILD)/obj/ejsArray.o
DEPS_110 += $(BUILD)/obj/ejsBlock.o
DEPS_110 += $(BUILD)/obj/ejsBoolean.o
DEPS_110 += $(BUILD)/obj/ejsByteArray.o
DEPS_110 += $(BUILD)/obj/ejsCache.o
DEPS_110 += $(BUILD)/obj/ejsCmd.o
DEPS_110 += $(BUILD)/obj/ejsConfig.o
DEPS_110 += $(BUILD)/obj/ejsDate.o
DEPS_110 += $(BUILD)/obj/ejsDebug.o
DEPS_110 += $(BUILD)/obj/ejsError.o
DEPS_110 += $(BUILD)/obj/ejsFile.o
DEPS_110 += $(BUILD)/obj/ejsFileSystem.o
DEPS_110 += $(BUILD)/obj/ejsFrame.o
DEPS_110 += $(BUILD)/obj/ejsFunction.o
DEPS_110 += $(BUILD)/obj/ejsGC.o
DEPS_110 += $(BUILD)/obj/ejsGlobal.o
DEPS_110 += $(BUILD)/obj/ejsHttp.o
DEPS_110 += $(BUILD)/obj/ejsIterator.o
DEPS_110 += $(BUILD)/obj/ejsJSON.o
DEPS_110 += $(BUILD)/obj/ejsLocalCache.o
DEPS_110 += $(BUILD)/obj/ejsMath.o
DEPS_110 += $(BUILD)/obj/ejsMemory.o
DEPS_110 += $(BUILD)/obj/ejsMprLog.o
DEPS_110 += $(BUILD)/obj/ejsNamespace.o
DEPS_110 += $(BUILD)/obj/ejsNull.o
DEPS_110 += $(BUILD)/obj/ejsNumber.o
DEPS_110 += $(BUILD)/obj/ejsObject.o
DEPS_110 += $(BUILD)/obj/ejsPath.o
DEPS_110 += $(BUILD)/obj/ejsPot.o
DEPS_110 += $(BUILD)/obj/ejsRegExp.o
DEPS_110 += $(BUILD)/obj/ejsSocket.o
DEPS_110 += $(BUILD)/obj/ejsString.o
DEPS_110 += $(BUILD)/obj/ejsSystem.o
DEPS_110 += $(BUILD)/obj/ejsTimer.o
DEPS_110 += $(BUILD)/obj/ejsType.o
DEPS_110 += $(BUILD)/obj/ejsUri.o
DEPS_110 += $(BUILD)/obj/ejsVoid.o
DEPS_110 += $(BUILD)/obj/ejsWebSocket.o
DEPS_110 += $(BUILD)/obj/ejsWorker.o
DEPS_110 += $(BUILD)/obj/ejsXML.o
DEPS_110 += $(BUILD)/obj/ejsXMLList.o
DEPS_110 += $(BUILD)/obj/ejsXMLLoader.o
DEPS_110 += $(BUILD)/obj/ejsByteCode.o
DEPS_110 += $(BUILD)/obj/ejsException.o
DEPS_110 += $(BUILD)/obj/ejsHelper.o
DEPS_110 += $(BUILD)/obj/ejsInterp.o
DEPS_110 += $(BUILD)/obj/ejsLoader.o
DEPS_110 += $(BUILD)/obj/ejsModule.o
DEPS_110 += $(BUILD)/obj/ejsScope.o
DEPS_110 += $(BUILD)/obj/ejsService.o

$(BUILD)/bin/libejs.out: $(DEPS_110)
	@echo '      [Link] $(BUILD)/bin/libejs.out'
	$(CC) -r -o $(BUILD)/bin/libejs.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ecAst.o" "$(BUILD)/obj/ecCodeGen.o" "$(BUILD)/obj/ecCompiler.o" "$(BUILD)/obj/ecLex.o" "$(BUILD)/obj/ecModuleWrite.o" "$(BUILD)/obj/ecParser.o" "$(BUILD)/obj/ecState.o" "$(BUILD)/obj/dtoa.o" "$(BUILD)/obj/ejsApp.o" "$(BUILD)/obj/ejsArray.o" "$(BUILD)/obj/ejsBlock.o" "$(BUILD)/obj/ejsBoolean.o" "$(BUILD)/obj/ejsByteArray.o" "$(BUILD)/obj/ejsCache.o" "$(BUILD)/obj/ejsCmd.o" "$(BUILD)/obj/ejsConfig.o" "$(BUILD)/obj/ejsDate.o" "$(BUILD)/obj/ejsDebug.o" "$(BUILD)/obj/ejsError.o" "$(BUILD)/obj/ejsFile.o" "$(BUILD)/obj/ejsFileSystem.o" "$(BUILD)/obj/ejsFrame.o" "$(BUILD)/obj/ejsFunction.o" "$(BUILD)/obj/ejsGC.o" "$(BUILD)/obj/ejsGlobal.o" "$(BUILD)/obj/ejsHttp.o" "$(BUILD)/obj/ejsIterator.o" "$(BUILD)/obj/ejsJSON.o" "$(BUILD)/obj/ejsLocalCache.o" "$(BUILD)/obj/ejsMath.o" "$(BUILD)/obj/ejsMemory.o" "$(BUILD)/obj/ejsMprLog.o" "$(BUILD)/obj/ejsNamespace.o" "$(BUILD)/obj/ejsNull.o" "$(BUILD)/obj/ejsNumber.o" "$(BUILD)/obj/ejsObject.o" "$(BUILD)/obj/ejsPath.o" "$(BUILD)/obj/ejsPot.o" "$(BUILD)/obj/ejsRegExp.o" "$(BUILD)/obj/ejsSocket.o" "$(BUILD)/obj/ejsString.o" "$(BUILD)/obj/ejsSystem.o" "$(BUILD)/obj/ejsTimer.o" "$(BUILD)/obj/ejsType.o" "$(BUILD)/obj/ejsUri.o" "$(BUILD)/obj/ejsVoid.o" "$(BUILD)/obj/ejsWebSocket.o" "$(BUILD)/obj/ejsWorker.o" "$(BUILD)/obj/ejsXML.o" "$(BUILD)/obj/ejsXMLList.o" "$(BUILD)/obj/ejsXMLLoader.o" "$(BUILD)/obj/ejsByteCode.o" "$(BUILD)/obj/ejsException.o" "$(BUILD)/obj/ejsHelper.o" "$(BUILD)/obj/ejsInterp.o" "$(BUILD)/obj/ejsLoader.o" "$(BUILD)/obj/ejsModule.o" "$(BUILD)/obj/ejsScope.o" "$(BUILD)/obj/ejsService.o" $(LIBS) 

#
#   ejs
#
DEPS_111 += $(BUILD)/bin/libejs.out
DEPS_111 += $(BUILD)/obj/ejs.o

$(BUILD)/bin/ejs.out: $(DEPS_111)
	@echo '      [Link] $(BUILD)/bin/ejs.out'
	$(CC) -o $(BUILD)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBS) -Wl,-r 

#
#   ejs.mod
#
DEPS_112 += src/core/App.es
DEPS_112 += src/core/Args.es
DEPS_112 += src/core/Array.es
DEPS_112 += src/core/BinaryStream.es
DEPS_112 += src/core/Block.es
DEPS_112 += src/core/Boolean.es
DEPS_112 += src/core/ByteArray.es
DEPS_112 += src/core/Cache.es
DEPS_112 += src/core/Cmd.es
DEPS_112 += src/core/Compat.es
DEPS_112 += src/core/Config.es
DEPS_112 += src/core/Date.es
DEPS_112 += src/core/Debug.es
DEPS_112 += src/core/Emitter.es
DEPS_112 += src/core/Error.es
DEPS_112 += src/core/File.es
DEPS_112 += src/core/FileSystem.es
DEPS_112 += src/core/Frame.es
DEPS_112 += src/core/Function.es
DEPS_112 += src/core/GC.es
DEPS_112 += src/core/Global.es
DEPS_112 += src/core/Http.es
DEPS_112 += src/core/Inflector.es
DEPS_112 += src/core/Iterator.es
DEPS_112 += src/core/JSON.es
DEPS_112 += src/core/Loader.es
DEPS_112 += src/core/LocalCache.es
DEPS_112 += src/core/Locale.es
DEPS_112 += src/core/Logger.es
DEPS_112 += src/core/Math.es
DEPS_112 += src/core/Memory.es
DEPS_112 += src/core/MprLog.es
DEPS_112 += src/core/Name.es
DEPS_112 += src/core/Namespace.es
DEPS_112 += src/core/Null.es
DEPS_112 += src/core/Number.es
DEPS_112 += src/core/Object.es
DEPS_112 += src/core/Path.es
DEPS_112 += src/core/Promise.es
DEPS_112 += src/core/RegExp.es
DEPS_112 += src/core/Socket.es
DEPS_112 += src/core/Stream.es
DEPS_112 += src/core/String.es
DEPS_112 += src/core/System.es
DEPS_112 += src/core/TextStream.es
DEPS_112 += src/core/Timer.es
DEPS_112 += src/core/Type.es
DEPS_112 += src/core/Uri.es
DEPS_112 += src/core/Void.es
DEPS_112 += src/core/WebSocket.es
DEPS_112 += src/core/Worker.es
DEPS_112 += src/core/XML.es
DEPS_112 += src/core/XMLHttp.es
DEPS_112 += src/core/XMLList.es

$(BUILD)/bin/ejs.mod: $(DEPS_112)
	( \
	cd src/core; \
	echo '   [Compile] Core EJS classes' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.mod  --optimize 9 --bind --require null App.es Args.es Array.es BinaryStream.es Block.es Boolean.es ByteArray.es Cache.es Cmd.es Compat.es Config.es Date.es Debug.es Emitter.es Error.es File.es FileSystem.es Frame.es Function.es GC.es Global.es Http.es Inflector.es Iterator.es JSON.es Loader.es LocalCache.es Locale.es Logger.es Math.es Memory.es MprLog.es Name.es Namespace.es Null.es Number.es Object.es Path.es Promise.es RegExp.es Socket.es Stream.es String.es System.es TextStream.es Timer.es Type.es Uri.es Void.es WebSocket.es Worker.es XML.es XMLHttp.es XMLList.es ; \
	null/ejsmod --cslots --dir ../../$(BUILD)/inc --require null ../../$(BUILD)/bin/ejs.mod ; \
	)

#
#   ejs.db.mod
#
DEPS_113 += src/ejs.db/Database.es
DEPS_113 += src/ejs.db/DatabaseConnector.es
DEPS_113 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.db.mod: $(DEPS_113)
	( \
	cd src/ejs.db; \
	echo '   [Compile] ejs.db.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.db.mod  --optimize 9 Database.es DatabaseConnector.es ; \
	)

#
#   ejs.db.mapper.mod
#
DEPS_114 += src/ejs.db.mapper/Record.es
DEPS_114 += $(BUILD)/bin/ejs.mod
DEPS_114 += $(BUILD)/bin/ejs.db.mod

$(BUILD)/bin/ejs.db.mapper.mod: $(DEPS_114)
	( \
	cd src/ejs.db.mapper; \
	echo '   [Compile] ejs.db.mapper.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.db.mapper.mod  --optimize 9 Record.es ; \
	)

#
#   ejs.db.sqlite.mod
#
DEPS_115 += src/ejs.db.sqlite/Sqlite.es
DEPS_115 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.db.sqlite.mod: $(DEPS_115)
	( \
	cd src/ejs.db.sqlite; \
	echo '   [Compile] ejs.db.sqlite.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.db.sqlite.mod  --optimize 9 Sqlite.es ; \
	null/ejsmod --cslots --dir ../../$(BUILD)/bin ../../$(BUILD)/bin/ejs.db.sqlite.mod ; \
	)

#
#   ejs.mail.mod
#
DEPS_116 += src/ejs.mail/Mail.es
DEPS_116 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.mail.mod: $(DEPS_116)
	( \
	cd src/ejs.mail; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.mail.mod  --optimize 9 Mail.es ; \
	)

#
#   ejs.web.mod
#
DEPS_117 += src/ejs.web/Cascade.es
DEPS_117 += src/ejs.web/CommonLog.es
DEPS_117 += src/ejs.web/ContentType.es
DEPS_117 += src/ejs.web/Controller.es
DEPS_117 += src/ejs.web/Dir.es
DEPS_117 += src/ejs.web/Google.es
DEPS_117 += src/ejs.web/Head.es
DEPS_117 += src/ejs.web/Html.es
DEPS_117 += src/ejs.web/HttpServer.es
DEPS_117 += src/ejs.web/MethodOverride.es
DEPS_117 += src/ejs.web/Middleware.es
DEPS_117 += src/ejs.web/Mvc.es
DEPS_117 += src/ejs.web/Request.es
DEPS_117 += src/ejs.web/Router.es
DEPS_117 += src/ejs.web/Script.es
DEPS_117 += src/ejs.web/Session.es
DEPS_117 += src/ejs.web/ShowExceptions.es
DEPS_117 += src/ejs.web/Static.es
DEPS_117 += src/ejs.web/Template.es
DEPS_117 += src/ejs.web/UploadFile.es
DEPS_117 += src/ejs.web/UrlMap.es
DEPS_117 += src/ejs.web/Utils.es
DEPS_117 += src/ejs.web/View.es
DEPS_117 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.web.mod: $(DEPS_117)
	( \
	cd src/ejs.web; \
	echo '   [Compile] ejs.web.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.web.mod  --optimize 9 Cascade.es CommonLog.es ContentType.es Controller.es Dir.es Google.es Head.es Html.es HttpServer.es MethodOverride.es Middleware.es Mvc.es Request.es Router.es Script.es Session.es ShowExceptions.es Static.es Template.es UploadFile.es UrlMap.es Utils.es View.es ; \
	null/ejsmod --cslots --dir ../../$(BUILD)/bin ../../$(BUILD)/bin/ejs.web.mod ; \
	)

#
#   ejs.template.mod
#
DEPS_118 += src/ejs.template/TemplateParser.es
DEPS_118 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.template.mod: $(DEPS_118)
	( \
	cd src/ejs.template; \
	echo '   [Compile] ejs.template.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.template.mod  --optimize 9 TemplateParser.es ; \
	)

#
#   ejs.unix.mod
#
DEPS_119 += src/ejs.unix/Unix.es
DEPS_119 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.unix.mod: $(DEPS_119)
	( \
	cd src/ejs.unix; \
	echo '   [Compile] ejs.unix.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.unix.mod  --optimize 9 Unix.es ; \
	)

#
#   ejs.mvc.mod
#
DEPS_120 += src/ejs.mvc/mvc.es
DEPS_120 += $(BUILD)/bin/ejs.mod
DEPS_120 += $(BUILD)/bin/ejs.web.mod
DEPS_120 += $(BUILD)/bin/ejs.template.mod
DEPS_120 += $(BUILD)/bin/ejs.unix.mod

$(BUILD)/bin/ejs.mvc.mod: $(DEPS_120)
	( \
	cd src/ejs.mvc; \
	echo '   [Compile] ejs.mvc.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.mvc.mod  --optimize 9 mvc.es ; \
	)

#
#   ejs.tar.mod
#
DEPS_121 += src/ejs.tar/Tar.es
DEPS_121 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.tar.mod: $(DEPS_121)
	( \
	cd src/ejs.tar; \
	echo '   [Compile] ejs.tar.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.tar.mod  --optimize 9 Tar.es ; \
	)

#
#   ejs.zlib.mod
#
DEPS_122 += src/ejs.zlib/Zlib.es
DEPS_122 += $(BUILD)/bin/ejs.mod

$(BUILD)/bin/ejs.zlib.mod: $(DEPS_122)
	( \
	cd src/ejs.zlib; \
	echo '   [Compile] ejs.zlib.mod' ; \
	null/ejsc --out ../../$(BUILD)/bin/ejs.zlib.mod  --optimize 9 Zlib.es ; \
	)


#
#   http-ca-crt
#
DEPS_123 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_123)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_124 += $(BUILD)/inc/sqlite3.h
DEPS_124 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_124)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	$(CC) -r -o $(BUILD)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   libejs.db.sqlite
#
DEPS_125 += $(BUILD)/bin/libmpr.out
DEPS_125 += $(BUILD)/bin/libejs.out
DEPS_125 += $(BUILD)/bin/ejs.mod
DEPS_125 += $(BUILD)/bin/ejs.db.sqlite.mod
ifeq ($(ME_COM_SQLITE),1)
    DEPS_125 += $(BUILD)/bin/libsql.out
endif
DEPS_125 += $(BUILD)/obj/ejsSqlite.o

$(BUILD)/bin/libejs.db.sqlite.out: $(DEPS_125)
	@echo '      [Link] $(BUILD)/bin/libejs.db.sqlite.out'
	$(CC) -r -o $(BUILD)/bin/libejs.db.sqlite.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsSqlite.o" $(LIBS) 

#
#   libejs.web
#
DEPS_126 += $(BUILD)/bin/libejs.out
DEPS_126 += $(BUILD)/bin/ejs.mod
DEPS_126 += $(BUILD)/inc/ejsWeb.h
DEPS_126 += $(BUILD)/obj/ejsHttpServer.o
DEPS_126 += $(BUILD)/obj/ejsRequest.o
DEPS_126 += $(BUILD)/obj/ejsSession.o
DEPS_126 += $(BUILD)/obj/ejsWeb.o

$(BUILD)/bin/libejs.web.out: $(DEPS_126)
	@echo '      [Link] $(BUILD)/bin/libejs.web.out'
	$(CC) -r -o $(BUILD)/bin/libejs.web.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsHttpServer.o" "$(BUILD)/obj/ejsRequest.o" "$(BUILD)/obj/ejsSession.o" "$(BUILD)/obj/ejsWeb.o" $(LIBS) 

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_127 += $(BUILD)/inc/zlib.h
DEPS_127 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.out: $(DEPS_127)
	@echo '      [Link] $(BUILD)/bin/libzlib.out'
	$(CC) -r -o $(BUILD)/bin/libzlib.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

#
#   libejs.zlib
#
DEPS_128 += $(BUILD)/bin/libejs.out
DEPS_128 += $(BUILD)/bin/ejs.mod
DEPS_128 += $(BUILD)/bin/ejs.zlib.mod
ifeq ($(ME_COM_ZLIB),1)
    DEPS_128 += $(BUILD)/bin/libzlib.out
endif
DEPS_128 += $(BUILD)/obj/ejsZlib.o

$(BUILD)/bin/libejs.zlib.out: $(DEPS_128)
	@echo '      [Link] $(BUILD)/bin/libejs.zlib.out'
	$(CC) -r -o $(BUILD)/bin/libejs.zlib.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsZlib.o" $(LIBS) 

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_129 += $(BUILD)/inc/est.h
DEPS_129 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.out: $(DEPS_129)
	@echo '      [Link] $(BUILD)/bin/libest.out'
	$(CC) -r -o $(BUILD)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

#
#   libmprssl
#
DEPS_130 += $(BUILD)/bin/libmpr.out
DEPS_130 += $(BUILD)/obj/mprSsl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_130 += -lssl
    LIBPATHS_130 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_130 += -lcrypto
    LIBPATHS_130 += -L$(ME_COM_OPENSSL_PATH)
endif

$(BUILD)/bin/libmprssl.out: $(DEPS_130)
	@echo '      [Link] $(BUILD)/bin/libmprssl.out'
	$(CC) -r -o $(BUILD)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_130) $(LIBS_130) $(LIBS_130) $(LIBS) 

#
#   manager
#
DEPS_131 += $(BUILD)/bin/libmpr.out
DEPS_131 += $(BUILD)/obj/manager.o

$(BUILD)/bin/ejsman.out: $(DEPS_131)
	@echo '      [Link] $(BUILD)/bin/ejsman.out'
	$(CC) -o $(BUILD)/bin/ejsman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBS) -Wl,-r 


#
#   installBinary
#
installBinary: $(DEPS_132)


#
#   install
#
DEPS_133 += stop
DEPS_133 += installBinary
DEPS_133 += start

install: $(DEPS_133)

#
#   uninstall
#
DEPS_134 += stop

uninstall: $(DEPS_134)

#
#   version
#
version: $(DEPS_135)
	echo 2.5.0

