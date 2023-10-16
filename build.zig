const std = @import("std");
const Builder = @import("std").build.Builder;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

const objFiles = [_][]u8{"main"};

var optimize: std.builtin.OptimizeMode = undefined;

pub fn build(b: *Builder) void {
    optimize = b.standardOptimizeOption(.{});
    const kernel = buildKernel(b);
    const entryother_step = buildEntryother(b);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);
    kernel_step.dependOn(entryother_step);

    const iso_dir = "./zig-cache/iso_root";
    const boot_dir = "./zig-cache/iso_root/boot";
    const grub_dir = "./zig-cache/iso_root/boot/grub";
    const kernel_path = std.fmt.allocPrint(std.heap.page_allocator, "./zig-out/bin/{s}", .{kernel.out_filename}) catch unreachable;
    const iso_path = b.fmt("{s}/disk.iso", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8{ "/bin/sh", "-c", std.mem.concat(b.allocator, u8, &[_][]const u8{ "mkdir -p ", grub_dir, " && ", "cp ", kernel_path, " ", boot_dir, " && ", "cp grub.cfg ", grub_dir, " && ", "grub-mkrescue -o ", iso_path, " ", iso_dir }) catch unreachable };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(kernel_step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);

    const run_cmd_str = &[_][]const u8{ "qemu-system-i386", "-drive", "file=zig-out/bin/disk.iso,index=0,media=disk,format=raw", "-m", "512", "-smp", "1", "-no-shutdown", "-no-reboot", "-nographic" };

    const run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}

fn buildEntryother(b: *Builder) *Builder.Step {
    const target = createTarget();

    const entryother = b.addExecutable(.{
        .name = "entryother.elf",
        .root_source_file = .{ .path = "src/entryother.zig" },
        .optimize = optimize,
        .target = target,
        .linkage = std.build.CompileStep.Linkage.static,
    });
    entryother.setLinkerScriptPath(.{ .path = "src/entryother.ld" });
    entryother.code_model = .kernel;
    b.installArtifact(entryother);

    const entryother_into_raw_binary = b.addSystemCommand(&[_][]const u8{ "objcopy", "--set-section-flags", ".bss=alloc,contents", "-O", "binary", "zig-out/bin/entryother.elf", "zig-out/bin/entryother" });
    entryother_into_raw_binary.step.dependOn(&entryother.step);

    const raw_binary_into_object = b.addSystemCommand(&[_][]const u8{ "objcopy", "-I", "binary", "-O", "elf32-i386", "-B", "i386", "zig-out/bin/entryother", "zig-out/bin/entryother.o" });
    raw_binary_into_object.step.dependOn(&entryother_into_raw_binary.step);

    return &raw_binary_into_object.step;
}

fn buildKernel(b: *Builder) *Builder.Step.Compile {
    const target = createTarget();

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
    kernel.addObject(main_obj);
    kernel.addObjectFile(Builder.LazyPath{ .path = "zig-out/bin/entryother.o" });
    kernel.code_model = .kernel;
    b.installArtifact(kernel);

    return kernel;
}

fn createTarget() CrossTarget {
    const features = Target.x86.Feature;

    var disabled_features = Feature.Set.empty;
    var enabled_features = Feature.Set.empty;

    disabled_features.addFeature(@intFromEnum(features.mmx));
    disabled_features.addFeature(@intFromEnum(features.sse));
    disabled_features.addFeature(@intFromEnum(features.sse2));
    disabled_features.addFeature(@intFromEnum(features.avx));
    disabled_features.addFeature(@intFromEnum(features.avx2));
    enabled_features.addFeature(@intFromEnum(features.soft_float));

    return CrossTarget{ .cpu_arch = Target.Cpu.Arch.x86, .os_tag = Target.Os.Tag.freestanding, .cpu_features_sub = disabled_features, .cpu_features_add = enabled_features };
}
