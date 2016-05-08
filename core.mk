#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
#||BUILD SCRIPT||# 
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
####| GENERATED FILE DIRECTORIES |####
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

OBJDIR = obj
BINDIR = bin
GENLIB = lib
FLAGSDIR = flags
MOCDIR = moc
ADDOBJDIR = addobj
TESTOBJDIR = testobj
NMDIR = nm

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
####| HELPER FUNCTIONS |####
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

##Function - findfiles##
#Description - Find files in the given directory recursively
#Arg $1 - directory path
#Return - List of files
findfiles=$(wildcard $1) $(foreach f,$(wildcard $1),$(call findfiles,$f/*))

##Function - filterext##
#Description - Find files with the given extensions in the given directory
#Arg 1 - list of extensions
#Arg 2 - directory path
#Return - List of files
filterext=$($1$2) $(foreach f, $(call findfiles, $2), $(filter $(addprefix %., $1), $f))

##Function - getdirectories##
#Description - Find a list of unique parent directories for a given list of files
#Arg 1 - list of files
#Return - List of directories
getdirectories=$($1) $(sort $(dir $1))

##Function - extractfilenames##
#Description - Extracts all but the directory-part of each file name in names
#Arg 1 - list of files
#Return - List of filenames
extractfilenames=$($1) $(sort $(notdir $1))

##Function - extractbasename##
#Description - Extracts all but the extension of each file name
#Arg 1 - list of files
#Return - List of basenames
extractbasename=$($1) $(sort $(basename $1))

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
####| VARIABLE DEFINITIONS |####
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Files and folders
MAINCODEDIRS=$(SRCDIR) $(INCDIR) $(TESTDIR)
MAINGENDIRS=$(addprefix $(BUILDDIR)/, $(BINDIR) $(GENLIB)/static $(GENLIB)/dynamic $(FLAGSDIR) $(TESTDIR) $(ADDOBJDIR))

SRCS = $(call filterext, $(SRCTYPES), $(SRCDIR))
SRCDIRNAMES = $(call getdirectories, $(SRCS))
INCS = $(call filterext, $(HTYPES), $(INCDIR))
INCDIRNAMES = $(call getdirectories, $(INCS))
EXTINCS = $(call filterext, $(HTYPES), $(EXTINC))
I_INCDIRS = $(addprefix -I, $(INCDIRNAMES))
I_EXTINCDIRS = $(addprefix -I, $(EXTINC))
D_DEFINES = $(addprefix -D, $(DEFINE))
L_LIBDIRS = $(addprefix -L, $(LIBDIRS))
l_LINKLIBS = $(addprefix -l, $(LIBS))

DEPS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/$(DEPDIR)/%.d, $(call extractbasename, $(SRCS)))
EXISTINGDEPS=$(call filterext, d, $(BUILDDIR)/$(DEPDIR))

ifeq ($(BUILD_TESTS),1)
TESTSRCS = $(call filterext, $(SRCTYPES), $(TESTDIR))
TESTSRCDIRNAMES = $(call getdirectories, $(TESTSRCS))
TESTINCS = $(call filterext, $(HTYPES), $(TESTDIR))
TESTINCDIRNAMES = $(call getdirectories, $(TESTINCS)) $(TESTINC)
I_TESTINCDIRS = $(addprefix -I, $(TESTINCDIRNAMES))
endif

ifeq ($(BUILD_MOCS),1)
MOCSRCS = $(patsubst $(INCDIR)/%.h, $(BUILDDIR)/$(MOCDIR)/%.cpp, $(INCS))
MOCOBJS = $(patsubst $(INCDIR)/%.h, $(BUILDDIR)/$(MOCDIR)/%.o, $(INCS))
MOCSRCDIRNAMES = $(call getdirectories, $(MOCSRCS))
endif

OBJS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/$(OBJDIR)/%.o, $(call extractbasename, $(SRCS)))
OBJDIRNAMES = $(call getdirectories, $(OBJS))
ADDOBJS = $(patsubst %, $(BUILDDIR)/$(ADDOBJDIR)/%.o, $(basename $(notdir $(ADDSRC))))

DEPS = $(patsubst %.o, %.d, $(OBJS))
EXISTINGDEPS=$(call filterext, d, $(BUILDDIR)/$(OBJDIR))

TESTOBJS = $(patsubst $(TESTDIR)/%,$(BUILDDIR)/$(TESTOBJDIR)/%.o, $(call extractbasename, $(TESTSRCS)))
TESTOBJDIRNAMES = $(call getdirectories, $(TESTOBJS))

TESTDEPS = $(patsubst %.o, %.d, $(TESTOBJS))
EXISTINGTESTDEPS = $(call filterext, d, $(BUILDDIR)/$(TESTOBJDIR))

NMS = $(patsubst $(SRCDIR)/%,$(BUILDDIR)/$(NMDIR)/%.nm, $(call extractbasename, $(SRCS)))
NMDIRNAMES = $(call getdirectories, $(NMS))

MAINOBJFILES=$(patsubst $(BUILDDIR)/$(NMDIR)/%, $(BUILDDIR)/$(OBJDIR)/%, $(call filterext, o, $(BUILDDIR)/$(NMDIR)))
NOTMAINOBJFILES=$(filter-out $(MAINOBJFILES), $(OBJS))

#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
####| TARGET RULES |####
#>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

### !! PHONY TARGETS !! ###

.PHONY: all
all:	$(BUILDDIR)/$(FLAGSDIR)/pre-build $(BUILDDIR)/$(FLAGSDIR)/$(PROJECT) $(BUILDDIR)/$(FLAGSDIR)/post-build

.PHONY: clean
clean:
	@echo "Cleaning..."
	rm -rf $(BUILDDIR) $(CLEANFILES)
	@echo "All done"

### !! MAIN TARGET TREE !! ###

GENDIRS_CONSTRUCT = $(OBJDIRNAMES) $(MAINGENDIRS) $(MAINCODEDIRS) $(TESTOBJDIRNAMES) $(NMDIRNAMES) $(MOCSRCDIRNAMES)
$(BUILDDIR)/$(FLAGSDIR)/gendirs: | $(GENDIRS_CONSTRUCT)
	@touch $@

$(BUILDDIR)/$(FLAGSDIR)/pre-build: $(BUILDDIR)/$(FLAGSDIR)/gendirs $(SRCS) $(TESTSRCS)
	@echo "Building" $(PROJECT) "Project"
ifeq ($(RUN_PREBUILD), 1)
	@echo "Running pre-build steps"
	$(PREBUILD)
	@echo "Pre-build steps complete"
endif
	@touch $@

GENOBJS_CONSTRUCT = $(OBJS) $(MOCOBJS) $(MOCSRCS) $(ADDOBJS) $(TESTOBJS) $(DEPS) $(TESTDEPS) $(NMS)
$(GENOBJS_CONSTRUCT) : | $(BUILDDIR)/$(FLAGSDIR)/pre-build 
$(BUILDDIR)/$(FLAGSDIR)/genobjs: $(GENOBJS_CONSTRUCT)
	@echo "Locating main obj files"
	$(eval MAINOBJFILES=$(patsubst $(BUILDDIR)/$(NMDIR)/%, $(BUILDDIR)/$(OBJDIR)/%, $(call filterext, o, $(BUILDDIR)/$(NMDIR))))
	$(eval NOTMAINOBJFILES=$(filter-out $(MAINOBJFILES), $(OBJS)))
	@echo "Main object files detected: $(MAINOBJFILES)"
	@touch $@

ifeq ($(BUILD_LIB), 1)
DYNAMIC_LIBRARY_CONSTRUCT = $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1.0 $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1 $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so
$(DYNAMIC_LIBRARY_CONSTRUCT) : $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build 

$(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1 $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so : $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1.0
$(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1.0 :
	@echo "Generating dynamic library lib$(PROJECT).so"
	$(CC) -fPIC $(CFLAGS) $(CPPFLAGS) -shared -Wl,-soname,lib$(PROJECT).so.1 -o $@ $(NOTMAINOBJFILES) $(ADDOBJS) $(MOCOBJS)
	ln -sf lib$(PROJECT).so.1.0 $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so.1
	ln -sf lib$(PROJECT).so.1.0 $(BUILDDIR)/$(GENLIB)/dynamic/lib$(PROJECT).so
	@echo "Dynamic library generated"

STATIC_LIBRARY_CONSTRUCT = $(BUILDDIR)/$(GENLIB)/static/lib$(PROJECT).a
$(STATIC_LIBRARY_CONSTRUCT) : $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build
$(BUILDDIR)/$(GENLIB)/static/lib$(PROJECT).a :
	@rm -rf $@
	@echo "Generating static library lib$(PROJECT).a"
	$(LG) $(LGOPTS) $@ $(NOTMAINOBJFILES) $(ADDOBJS) $(MOCOBJS)
	@echo "Static Library generated"
endif

$(BUILDDIR)/$(FLAGSDIR)/linklibsdynamic: $(DYNAMIC_LIBRARY_CONSTRUCT) $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build 
	@touch $@
	
$(BUILDDIR)/$(FLAGSDIR)/linklibsstatic: $(STATIC_LIBRARY_CONSTRUCT) $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build
	@touch $@

define linkbin
	@echo "$(CC) -Wl,-unresolved-symbols=ignore-in-shared-libs $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $1 $(NOTMAINOBJFILES) $(ADDOBJS) $(MOCOBJS) $(LINKS) $(L_LIBDIRS) $(l_LINKLIBS) $(I_INCDIRS) $(I_EXTINCDIRS) -o $(BUILDDIR)/$(BINDIR)/$(PROJECT)$(notdir $(basename $1))"
	$(CC) -Wl,-unresolved-symbols=ignore-in-shared-libs $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $1 $(NOTMAINOBJFILES) $(ADDOBJS) $(MOCOBJS) $(LINKS) $(L_LIBDIRS) $(l_LINKLIBS) $(I_INCDIRS) $(I_EXTINCDIRS) -o $(BUILDDIR)/$(BINDIR)/$(PROJECT)$(notdir $(basename $1)) || exit
endef

$(BUILDDIR)/$(FLAGSDIR)/linkbins: $(BUILDDIR)/$(BINDIR) $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build
ifeq ($(BUILD_BIN), 1)
	@echo "Building binaries"
	@$(foreach obj, $(MAINOBJFILES), $(call linkbin, $(obj)))
	@echo "Binaries generated"
endif
	@touch $@

ifeq ($(BUILD_TESTS), 1)
TEST_BINARY_CONSTRUCT = $(BUILDDIR)/test/$(PROJECT)Tester
$(TEST_BINARY_CONSTRUCT) : $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build
$(BUILDDIR)/test/$(PROJECT)Tester :
	@echo "Generating tests:"
	$(CC) -Wl,-unresolved-symbols=ignore-in-shared-libs $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $(NOTMAINOBJFILES) $(MOCOBJS) $(ADDOBJS) $(TESTOBJS) $(TESTLIB) $(LINKS) $(L_LIBDIRS) $(l_LINKLIBS) $(I_INCDIRS) $(I_EXTINCDIRS) $(I_TESTINCDIRS) -o $(BUILDDIR)/test/$(PROJECT)Tester
	@echo "Tests generated"
endif

$(BUILDDIR)/$(FLAGSDIR)/linktests: $(TEST_BINARY_CONSTRUCT) $(BUILDDIR)/$(FLAGSDIR)/genobjs | $(BUILDDIR)/$(FLAGSDIR)/pre-build
	@touch $@
	
$(BUILDDIR)/$(FLAGSDIR)/$(PROJECT): $(BUILDDIR)/$(FLAGSDIR)/linklibsdynamic $(BUILDDIR)/$(FLAGSDIR)/linklibsstatic $(BUILDDIR)/$(FLAGSDIR)/linkbins $(BUILDDIR)/$(FLAGSDIR)/linktests | $(BUILDDIR)/$(FLAGSDIR)/pre-build
	@touch $@
	
$(BUILDDIR)/$(FLAGSDIR)/post-build: $(BUILDDIR)/$(FLAGSDIR)/$(PROJECT) $(BUILDDIR)/$(FLAGSDIR)/linklibsstatic $(BUILDDIR)/$(FLAGSDIR)/linklibsdynamic $(BUILDDIR)/$(FLAGSDIR)/genobjs $(BUILDDIR)/$(FLAGSDIR)/pre-build $(BUILDDIR)/$(FLAGSDIR)/gendirs
ifeq ($(RUN_POSTBUILD), 1)
	@echo "Running post-build steps"
	$(POSTBUILD)
	@echo "Post-build steps complete"
endif
	@echo "Build complete"
	@touch $(BUILDDIR)/$(FLAGSDIR)/pre-build
	@touch $@

### !! MAIN TARGET RULES !! ###

define directory_rule
$1:
	@mkdir -p $1
endef
$(foreach CODEDIR, $(MAINCODEDIRS), $(eval $(call directory_rule,$(CODEDIR))))
$(foreach GENDIR, $(MAINGENDIRS), $(eval $(call directory_rule,$(GENDIR))))
$(foreach OBJDIR, $(OBJDIRNAMES), $(eval $(call directory_rule,$(OBJDIR))))
$(foreach NMDIR, $(NMDIRNAMES), $(eval $(call directory_rule,$(NMDIR))))
$(foreach TOBJDIR_F, $(TESTOBJDIRNAMES), $(eval $(call directory_rule,$(TOBJDIR_F))))
$(foreach MOCSRCDIR_F, $(MOCSRCDIRNAMES), $(eval $(call directory_rule, $(MOCSRCDIR_F))))

#Defines the compilation rule 
define compile_rule
$(BUILDDIR)/$(OBJDIR)/%.d : $(BUILDDIR)/$(OBJDIR)/%.o
$(BUILDDIR)/$(OBJDIR)/%.o : $(SRCDIR)/%.$1 
	@echo "Compiling $$<"
	$(CC) $(OPTS) $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $(I_INCDIRS) $(I_EXTINCDIRS) -MP -MMD -c $$< -o $$@
	@echo "Completed compilation of $$<"

$(BUILDDIR)/$(TESTOBJDIR)/%.d : $(BUILDDIR)/$(TESTOBJDIR)/%.o
$(BUILDDIR)/$(TESTOBJDIR)/%.o : $(TESTDIR)/%.$1 
	@echo "Compiling $$<"
	$(CC) $(OPTS) $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $(I_INCDIRS) $(I_TESTINCDIRS) $(I_EXTINCDIRS) -MP -MMD -c $$< -o $$@
	@echo "Completed compilation of $$<"
endef
$(foreach SRCTYPE, $(SRCTYPES), $(eval $(call compile_rule,$(SRCTYPE))))
$(eval include $(EXISTINGDEPS))
$(eval include $(EXISTINGTESTDEPS))

$(BUILDDIR)/$(NMDIR)/%.nm : | $(BUILDDIR)/$(OBJDIR)/%.o
	@echo "Searching for main method in " $(patsubst $(BUILDDIR)/$(NMDIR)/%.nm, $(BUILDDIR)/$(OBJDIR)/%.o, $@)
	@nm --defined-only --format=sysv $(patsubst $(BUILDDIR)/$(NMDIR)/%.nm, $(BUILDDIR)/$(OBJDIR)/%.o, $@) | cut -f1 -d ' ' | grep -q -x main && touch $(patsubst %.nm, %.o, $@) || :
	@touch $@

#Compile additional objects
define compile_rule_addobjs
$(patsubst %, $(BUILDDIR)/$(ADDOBJDIR)/%.o, $(basename $(notdir $1))): $1
	@echo "Compiling $$<:"
	$(CC) $(OPTS) $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $(I_INCDIRS) $(I_EXTINCDIRS) -c $$< -o $$@
endef
$(foreach ASRC, $(ADDSRC),$(eval $(call compile_rule_addobjs,$(ASRC))))

#Compile moc files
define moc_src_rule
$(BUILDDIR)/$(MOCDIR)/%.cpp : $(INCDIR)/%.$1
	@echo "Mocing $$<:"
	moc $$< -o $$@
endef
$(foreach HTYPE, $(HTYPES),$(eval $(call moc_src_rule,$(HTYPE))))

$(BUILDDIR)/$(MOCDIR)/%.o : $(BUILDDIR)/$(MOCDIR)/%.cpp
	@echo "Compiling MOC file $<:"
	$(CC) $(OPTS) $(D_DEFINES) $(CFLAGS) $(CPPFLAGS) $(I_INCDIRS) $(I_EXTINCDIRS) -c $< -o $@