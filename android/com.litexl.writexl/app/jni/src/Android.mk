LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := main

SDL_PATH := ../SDL

LOCAL_C_INCLUDES := $(LOCAL_PATH)/$(SDL_PATH)/include $(LOCAL_PATH)/lite-xl-simplified/lib/freetype/include $(LOCAL_PATH)/lite-xl-simplified/lib/lua $(LOCAL_PATH)/lite-xl-simplified/lib/pcre2/src
LOCAL_CFLAGS := -DPCRE2_STATIC  -DHAVE_CONFIG_H -DPCRE2_CODE_UNIT_WIDTH=8  -DFT2_BUILD_LIBRARY -DANDROID_TOOLCHAIN=clang -g
LOCAL_LDFLAGS := -lm
# Add your application source files here...
LOCAL_SRC_FILES :=  lite-xl-simplified/src/renwindow.c lite-xl-simplified/src/renderer.c lite-xl-simplified/src/main.c lite-xl-simplified/src/api/api.c lite-xl-simplified/src/api/renderer.c  \
lite-xl-simplified/src/api/regex.c lite-xl-simplified/src/api/system.c lite-xl-simplified/src/api/dirmonitor.c lite-xl-simplified/src/api/process.c lite-xl-simplified/src/rencache.c \
lite-xl-simplified/lib/lua/lapi.c lite-xl-simplified/lib/lua/lauxlib.c lite-xl-simplified/lib/lua/lbaselib.c lite-xl-simplified/lib/lua/lcode.c lite-xl-simplified/lib/lua/lcorolib.c lite-xl-simplified/lib/lua/lctype.c lite-xl-simplified/lib/lua/ldblib.c lite-xl-simplified/lib/lua/ldebug.c\
lite-xl-simplified/lib/lua/ldo.c lite-xl-simplified/lib/lua/ldump.c lite-xl-simplified/lib/lua/lfunc.c lite-xl-simplified/lib/lua/lgc.c lite-xl-simplified/lib/lua/linit.c lite-xl-simplified/lib/lua/liolib.c lite-xl-simplified/lib/lua/llex.c lite-xl-simplified/lib/lua/lmathlib.c lite-xl-simplified/lib/lua/lmem.c lite-xl-simplified/lib/lua/loadlib.c\
lite-xl-simplified/lib/lua/lobject.c lite-xl-simplified/lib/lua/lopcodes.c lite-xl-simplified/lib/lua/loslib.c lite-xl-simplified/lib/lua/lparser.c lite-xl-simplified/lib/lua/lstate.c lite-xl-simplified/lib/lua/lstring.c lite-xl-simplified/lib/lua/lstrlib.c lite-xl-simplified/lib/lua/ltable.c lite-xl-simplified/lib/lua/ltablib.c\
lite-xl-simplified/lib/lua/ltests.c lite-xl-simplified/lib/lua/ltm.c lite-xl-simplified/lib/lua/lua.c lite-xl-simplified/lib/lua/lundump.c lite-xl-simplified/lib/lua/lutf8lib.c lite-xl-simplified/lib/lua/lvm.c lite-xl-simplified/lib/lua/lzio.c\
lite-xl-simplified/lib/pcre2/src/pcre2_substitute.c lite-xl-simplified/lib/pcre2/src/pcre2_convert.c lite-xl-simplified/lib/pcre2/src/pcre2_dfa_match.c lite-xl-simplified/lib/pcre2/src/pcre2_find_bracket.c\
lite-xl-simplified/lib/pcre2/src/pcre2_auto_possess.c lite-xl-simplified/lib/pcre2/src/pcre2_substring.c lite-xl-simplified/lib/pcre2/src/pcre2_match_data.c lite-xl-simplified/lib/pcre2/src/pcre2_xclass.c lite-xl-simplified/lib/pcre2/src/pcre2_study.c\
lite-xl-simplified/lib/pcre2/src/pcre2_ucd.c lite-xl-simplified/lib/pcre2/src/pcre2_maketables.c lite-xl-simplified/lib/pcre2/src/pcre2_compile.c lite-xl-simplified/lib/pcre2/src/pcre2_match.c lite-xl-simplified/lib/pcre2/src/pcre2_context.c\
lite-xl-simplified/lib/pcre2/src/pcre2_string_utils.c lite-xl-simplified/lib/pcre2/src/pcre2_tables.c lite-xl-simplified/lib/pcre2/src/pcre2_serialize.c lite-xl-simplified/lib/pcre2/src/pcre2_ord2utf.c lite-xl-simplified/lib/pcre2/src/pcre2_error.c\
lite-xl-simplified/lib/pcre2/src/pcre2_config.c lite-xl-simplified/lib/pcre2/src/pcre2_chartables.c lite-xl-simplified/lib/pcre2/src/pcre2_newline.c lite-xl-simplified/lib/pcre2/src/pcre2_jit_compile.c lite-xl-simplified/lib/pcre2/src/pcre2_fuzzsupport.c\
lite-xl-simplified/lib/pcre2/src/pcre2_valid_utf.c lite-xl-simplified/lib/pcre2/src/pcre2_extuni.c lite-xl-simplified/lib/pcre2/src/pcre2_script_run.c lite-xl-simplified/lib/pcre2/src/pcre2_pattern_info.c\
lite-xl-simplified/lib/freetype/src/smooth/smooth.c lite-xl-simplified/lib/freetype/src/truetype/truetype.c lite-xl-simplified/lib/freetype/src/autofit/autofit.c lite-xl-simplified/lib/freetype/src/pshinter/pshinter.c\
lite-xl-simplified/lib/freetype/src/psaux/psaux.c lite-xl-simplified/lib/freetype/src/psnames/psnames.c lite-xl-simplified/lib/freetype/src/sfnt/sfnt.c lite-xl-simplified/lib/freetype/src/base/ftsystem.c lite-xl-simplified/lib/freetype/src/base/ftinit.c\
lite-xl-simplified/lib/freetype/src/base/ftdebug.c lite-xl-simplified/lib/freetype/src/base/ftbase.c lite-xl-simplified/lib/freetype/src/base/ftbbox.c lite-xl-simplified/lib/freetype/src/base/ftglyph.c lite-xl-simplified/lib/freetype/src/base/ftbdf.c\
lite-xl-simplified/lib/freetype/src/base/ftbitmap.c lite-xl-simplified/lib/freetype/src/base/ftcid.c lite-xl-simplified/lib/freetype/src/base/ftfstype.c lite-xl-simplified/lib/freetype/src/base/ftgasp.c lite-xl-simplified/lib/freetype/src/base/ftgxval.c\
lite-xl-simplified/lib/freetype/src/base/ftmm.c lite-xl-simplified/lib/freetype/src/base/ftotval.c lite-xl-simplified/lib/freetype/src/base/ftpatent.c lite-xl-simplified/lib/freetype/src/base/ftpfr.c lite-xl-simplified/lib/freetype/src/base/ftstroke.c\
lite-xl-simplified/lib/freetype/src/base/ftsynth.c lite-xl-simplified/lib/freetype/src/base/fttype1.c lite-xl-simplified/lib/freetype/src/base/ftwinfnt.c lite-xl-simplified/lib/freetype/src/type1/type1.c lite-xl-simplified/lib/freetype/src/cff/cff.c\
lite-xl-simplified/lib/freetype/src/pfr/pfr.c lite-xl-simplified/lib/freetype/src/cid/type1cid.c lite-xl-simplified/lib/freetype/src/winfonts/winfnt.c lite-xl-simplified/lib/freetype/src/type42/type42.c lite-xl-simplified/lib/freetype/src/pcf/pcf.c\
lite-xl-simplified/lib/freetype/src/bdf/bdf.c lite-xl-simplified/lib/freetype/src/raster/raster.c lite-xl-simplified/lib/freetype/src/sdf/sdf.c lite-xl-simplified/lib/freetype/src/gzip/ftgzip.c lite-xl-simplified/lib/freetype/src/lzw/ftlzw.c \
lite-xl-simplified/lib/freetype/src/svg/ftsvg.c

LOCAL_SHARED_LIBRARIES := SDL2 
LOCAL_LDLIBS := -lOpenSLES -llog -landroid

include $(BUILD_SHARED_LIBRARY)
