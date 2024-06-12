const std = @import("std");
const Builder = @import("std").build.Builder;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

const objFiles = [_][]u8{"main"};

pub fn build(b: *Builder) void {
    const features = Target.x86.Feature;

    var disabled_features = Feature.Set.empty;
    var enabled_features = Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(features.mmx));
    disabled_features.addFeature(@intFromEnum(features.sse));
    disabled_features.addFeature(@intFromEnum(features.sse2));
    disabled_features.addFeature(@intFromEnum(features.avx));
    disabled_features.addFeature(@intFromEnum(features.avx2));
    enabled_features.addFeature(@intFromEnum(features.soft_float));

    const target = CrossTarget{ .cpu_arch = Target.Cpu.Arch.x86, .os_tag = Target.Os.Tag.freestanding, .cpu_features_sub = disabled_features, .cpu_features_add = enabled_features };

    const optimize = b.standardOptimizeOption(.{});

    const build_initcode_step = buildInitcode(b);

    // objects for assembly
    const main_obj = b.addObject(std.Build.ObjectOptions{
        .name = "main",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    const kernel = b.addExecutable(.{
        .name = "kernel.elf",
        .root_source_file = .{ .path = "src/entry.zig" },
        .optimize = optimize,
        .target = target,
        .linkage = std.build.CompileStep.Linkage.static,
    });
    kernel.setLinkerScriptPath(.{ .path = "src/kernel.ld" });
    kernel.addAssemblyFile(.{ .path = "src/trapasm.S" });
    kernel.addAssemblyFile(.{ .path = "src/vector.S" });
    kernel.addAssemblyFile(.{ .path = "src/swtch.S" });
    kernel.addObject(main_obj);
    kernel.addObjectFile(.{ .path = "zig-out/bin/initcode.o" });
    kernel.code_model = .kernel;
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    kernel.step.dependOn(build_initcode_step);

    const run_cmd_str = [_][]const u8{
        "qemu-system-i386",
        "-kernel",
        "zig-out/bin/kernel.elf",
        "-m",
        "512",
        "-smp",
        "1",
        "-no-shutdown",
        "-no-reboot",
        "-nographic",
        "-gdb",
        "tcp::1234",
    };

    const run_cmd = b.addSystemCommand(&run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);

    const debug_cmd_str = run_cmd_str ++ [_][]const u8{
        "-S",
    };

    const debug_cmd = b.addSystemCommand(&debug_cmd_str);
    debug_cmd.step.dependOn(b.getInstallStep());

    const debug_step = b.step("debug", "Debug the kernel");
    debug_step.dependOn(&debug_cmd.step);
}

fn buildInitcode(b: *Builder) *std.Build.Step {
    const build_initcode_command = b.addSystemCommand(&[_][]const u8{"./scripts/build_initcode.sh"});
    return &build_initcode_command.step;
}
