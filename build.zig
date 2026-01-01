const std = @import("std");
const Build = @import("std").Build;
const Target = @import("std").Target;
const Query = @import("std").Target.Query;

const objFiles = [_][]u8{"main"};

pub fn build(b: *Build) void {
        const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .freestanding,
        .ofmt = .elf,
    });
        const optimize = b.standardOptimizeOption(.{});

    const build_initcode_step = buildInitcode(b);

    const main_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .kernel,
    });
    const main_obj = b.addObject(std.Build.ObjectOptions{
        .name = "main",
        .root_module = main_module,
    });

    const kernel_module = b.createModule(.{
        .root_source_file = b.path("src/entry.zig"),
        .target = target,
        .optimize = optimize,
        .code_model = .kernel,
    });
    const kernel = b.addExecutable(Build.ExecutableOptions{
        .name = "kernel.elf",
        .root_module = kernel_module,
        .linkage = std.builtin.LinkMode.static,
    });
    kernel.linker_script = b.path("src/kernel.ld");
    kernel_module.addAssemblyFile(.{ .src_path = .{ .owner = b, .sub_path = "src/trapasm.S" } });
    kernel_module.addAssemblyFile(.{ .src_path = .{ .owner = b, .sub_path = "src/vector.S" } });
    kernel_module.addAssemblyFile(.{ .src_path = .{ .owner = b, .sub_path = "src/swtch.S" } });
    kernel_module.addObject(main_obj);
    kernel_module.addObjectFile(.{ .src_path = .{ .owner = b, .sub_path = "zig-out/bin/initcode.o" } });
    b.installArtifact(kernel);

    const kernel_step = b.step("kernel", "Build the kernel");
    kernel_step.dependOn(&kernel.step);

    kernel.step.dependOn(build_initcode_step);

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

    const run_cmd_str = [_][]const u8{
        "qemu-system-i386",
        "-drive",
        "file=zig-out/bin/disk.iso,index=0,media=disk,format=raw",
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

fn buildInitcode(b: *Build) *std.Build.Step {
    const build_initcode_command = b.addSystemCommand(&[_][]const u8{"./scripts/build_initcode.sh"});
    return &build_initcode_command.step;
}
