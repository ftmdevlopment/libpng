LOCAL_PATH:= $(call my-dir)

# We need to build this for both the device (as a shared library)
# and the host (as a static library for tools to use).

common_SRC_FILES := \
	png.c \
	pngerror.c \
	pngget.c \
	pngmem.c \
	pngpread.c \
	pngread.c \
	pngrio.c \
	pngrtran.c \
	pngrutil.c \
	pngset.c \
	pngtrans.c \
	pngwio.c \
	pngwrite.c \
	pngwtran.c \
	pngwutil.c \

ifeq ($(ARCH_ARM_HAVE_NEON),true)
my_cflags_arm := -DPNG_ARM_NEON_OPT=2
endif

my_cflags_arm64 := -DPNG_ARM_NEON_OPT=2

# BUG: http://llvm.org/PR19472 - SLP vectorization (on ARM at least) crashes
# when we can't lower a vectorized bswap.
my_cflags_arm += -fno-slp-vectorize

my_src_files_arm := \
			arm/arm_init.c \
			arm/filter_neon.S \
			arm/filter_neon_intrinsics.c


common_CFLAGS := -std=gnu89 #-fvisibility=hidden ## -fomit-frame-pointer

ifeq ($(HOST_OS),windows)
	ifeq ($(USE_MINGW),)
#		Case where we're building windows but not under linux (so it must be cygwin)
#		In this case, gcc cygwin doesn't recognize -fvisibility=hidden
		$(info libpng: Ignoring gcc flag $(common_CFLAGS) on Cygwin)
	common_CFLAGS :=
	endif
endif

ifeq ($(HOST_OS),darwin)
common_CFLAGS += -no-integrated-as
common_ASFLAGS += -no-integrated-as
endif

common_C_INCLUDES +=

common_COPY_HEADERS_TO := libpng
common_COPY_HEADERS := png.h pngconf.h pngusr.h


# For the device (static)
# =====================================================

include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_SRC_FILES := $(common_SRC_FILES)
LOCAL_SRC_FILES += $(my_src_files_arm)
LOCAL_CFLAGS += $(common_CFLAGS) -ftrapv
LOCAL_CFLAGS += $(my_cflags_arm)

LOCAL_ASFLAGS += $(common_ASFLAGS)


LOCAL_C_INCLUDES += $(common_C_INCLUDES)
LOCAL_SHARED_LIBRARIES := \
	libz

LOCAL_MODULE:= libpng

include $(BUILD_STATIC_LIBRARY)

# For testing
# =====================================================

include $(CLEAR_VARS)
LOCAL_CLANG := true
LOCAL_C_INCLUDES:= $(common_C_INCLUDES)
LOCAL_SRC_FILES:= pngtest.c
LOCAL_MODULE := pngtest
LOCAL_SHARED_LIBRARIES:= libpng libz
LOCAL_MODULE_TAGS := debug
include $(BUILD_EXECUTABLE)
