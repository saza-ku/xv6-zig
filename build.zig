const std = @import("std");
const Builder = @import("std").build.Builder;
const Target = @import("std").Target;
const CrossTarget = @import("std").zig.CrossTarget;
const Feature = @import("std").Target.Cpu.Feature;

pub fn build(b: *Builder) void {
    const target = CrossTarget{
        .cpu_arch = Target.Cpu.Arch.i386,
        .os_tag = Target.Os.Tag.freestanding,
    };

    const mode = b.standardReleaseOptions();

    const kernel = b.addExecutable("kernel.elf", "src/entry.zig");
    kernel.setTarget(target);
    kernel.setBuildMode(mode);
    kernel.setLinkerScriptPath(.{ .path = "src/kernel.ld" });
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

    const run_cmd_str = &[_][]const u8{ "qemu-system-x86_64", "-cdrom", iso_path, "-debugcon", "stdio", "-vga", "virtio", "-m", "4G", "-machine", "q35,accel=kvm:whpx:tcg", "-no-reboot", "-no-shutdown" };

    const run_cmd = b.addSystemCommand(run_cmd_str);
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the kernel");
    run_step.dependOn(&run_cmd.step);
}
