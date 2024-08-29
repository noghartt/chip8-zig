const std = @import("std");

const chip8 = @import("chip8.zig");

pub fn main() !void {
    const args = try std.process.argsAlloc(std.heap.page_allocator);
    const file = args[1];
    const rom = try load_file(file);
    const chip = chip8.init();
    chip.load_rom(rom);
}

fn load_file(path: []const u8) ![]u8 {
    return try std.fs.cwd().readFileAlloc(std.heap.page_allocator, path, 0x10000);
}
