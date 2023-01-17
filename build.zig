const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const ffmpeg_dep = b.dependency("ffmpeg", .{});

    const lib = b.addStaticLibrary("chromaprint", null);
    lib.setTarget(target);
    lib.setBuildMode(mode);
    lib.linkLibrary(ffmpeg_dep.artifact("ffmpeg"));
    lib.linkLibC();
    lib.linkLibCpp();
    lib.addIncludePath("src");
    lib.addConfigHeader(b.addConfigHeader(.{ .path = "config.h.in" }, .cmake, .{
        .HAVE_ROUND = 1,
        .HAVE_LRINTF = 1,
        .HAVE_AV_PACKET_UNREF = 1,
        .HAVE_AV_FRAME_ALLOC = 1,
        .HAVE_AV_FRAME_FREE = 1,
        .TESTS_DIR = "/dev/null",
        .USE_SWRESAMPLE = 1,
        .USE_AVRESAMPLE = 1,
        .USE_INTERNAL_AVRESAMPLE = null,
        .USE_AVFFT = 1,
        .USE_FFTW3 = null,
        .USE_FFTW3F = null,
        .USE_VDSP = null,
        .USE_KISSFFT = null,
    }));
    lib.addCSourceFiles(&.{
        "src/audio_processor.cpp",
        "src/chroma.cpp",
        "src/chroma_resampler.cpp",
        "src/chroma_filter.cpp",
        "src/spectrum.cpp",
        "src/fft.cpp",
        "src/fingerprinter.cpp",
        "src/image_builder.cpp",
        "src/simhash.cpp",
        "src/silence_remover.cpp",
        "src/fingerprint_calculator.cpp",
        "src/fingerprint_compressor.cpp",
        "src/fingerprint_decompressor.cpp",
        "src/fingerprinter_configuration.cpp",
        "src/fingerprint_matcher.cpp",
        "src/utils/base64.cpp",
        "src/chromaprint.cpp",
        "src/fft_lib_avfft.cpp",
    }, &.{
        "-std=c++11",
        "-fno-rtti",
        "-fno-exceptions",
        "-DHAVE_CONFIG_H",
        "-D_SCL_SECURE_NO_WARNINGS",
        "-D__STDC_LIMIT_MACROS",
        "-D__STDC_CONSTANT_MACROS",
        "-DCHROMAPRINT_NODLL",
    });
    lib.addCSourceFiles(&.{
        "src/avresample/resample2.c",
    }, &.{
        "-std=c11",
        "-DHAVE_CONFIG_H",
        "-D_SCL_SECURE_NO_WARNINGS",
        "-D__STDC_LIMIT_MACROS",
        "-D__STDC_CONSTANT_MACROS",
        "-DCHROMAPRINT_NODLL",
        "-D_GNU_SOURCE",
    });
    lib.install();
    lib.installHeader("src/chromaprint.h", "chromaprint.h");
}
