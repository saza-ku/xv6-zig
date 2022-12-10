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

    disabled_features.addFeature(@enumToInt(features.mmx));
    disabled_features.addFeature(@enumToInt(features.sse));
    disabled_features.addFeature(@enumToInt(features.sse2));
    disabled_features.addFeature(@enumToInt(features.avx));
    disabled_features.addFeature(@enumToInt(features.avx2));
    enabled_features.addFeature(@enumToInt(features.soft_float));

    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.x86,
        .os_tag = Target.Os.Tag.freestanding,
        .cpu_features_sub = disabled_features,
        .cpu_features_add = enabled_features
    };

    const mode = b.standardReleaseOptions();

    // objects for assembly
    const main_obj = b.addObject("main", "src/main.zig");
    main_obj.setTarget(target);
    main_obj.setBuildMode(mode);

    const kernel = b.addExecutable("kernel.elf", "src/entry.zig");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.setLinkerScriptPath(.{ .path = "src/kernel.ld" });
    kernel.addAssemblyFile("src/trapasm.S");
    kernel.addAssemblyFile("src/vector.S");
    kernel.addAssemblyFile("src/entry_other.S");
    kernel.addObject(main_obj);
    kernel.code_model = .kernel;
    kernel.install();

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.install_step.?.step);

    const iso_dir = b.fmt("{s}/iso_root", .{b.cache_root});
    const boot_dir = b.fmt("{s}/iso_root/boot", .{b.cache_root});
    const grub_dir = b.fmt("{s}/iso_root/boot/grub", .{b.cache_root});
    const kernel_path = b.getInstallPath(kernel.install_step.?.dest_dir, kernel.out_filename);
    const iso_path = b.fmt("{s}/disk.iso", .{b.exe_dir});

    const iso_cmd_str = &[_][]const u8{ "/bin/sh", "-c", std.mem.concat(b.allocator, u8, &[_][]const u8{ "mkdir -p ", grub_dir, " && ", "cp ", kernel_path, " ", boot_dir, " && ", "cp grub.cfg ", grub_dir, " && ", "grub-mkrescue -o ", iso_path, " ", iso_dir }) catch unreachable };

    const iso_cmd = b.addSystemCommand(iso_cmd_str);
    iso_cmd.step.dependOn(kernel_step);

    const iso_step = b.step("iso", "Build an ISO image");
    iso_step.dependOn(&iso_cmd.step);
    b.default_step.dependOn(iso_step);

    const run_cmd_str = &[_][]const u8{ "qemu-system-i386", "-monitor", "stdio", "-drive", "file=zig-out/bin/disk.iso,index=0,media=disk,format=raw", "-drive", "file=zig-out/bin/disk1.iso,index=1,media=disk,format=raw", "-m", "512", "-smp", "2", "-no-shutdown", "-no-reboot" };

    const run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}
