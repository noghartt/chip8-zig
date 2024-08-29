const std = @import("std");
const chip8 = @import("chip8.zig");

test "expect chip8 to load fontset" {
    const chip = chip8.init();

    try std.testing.expectEqual(chip.memory[0x50], 0xF0);
    try std.testing.expectEqual(chip.memory[0x50 + 79], 0x80);
}

test "expect chip8 to load rom" {
    var chip = chip8.init();
    const rom = &[_]u8{ 0x00, 0x01, 0x02, 0x03 };
    chip.load_rom(rom);

    try std.testing.expectEqual(chip.pc, 0x200);
    try std.testing.expectEqual(chip.memory[0x200], 0x00);
    try std.testing.expectEqual(chip.memory[0x200 + 1], 0x01);
    try std.testing.expectEqual(chip.memory[0x200 + 2], 0x02);
    try std.testing.expectEqual(chip.memory[0x200 + 3], 0x03);
}

test "expect chip8 to emulate opcode 00e0" {
    var chip = chip8.init();
    const rom = &[_]u8{ 0x00, 0xE0, 0x00, 0x01 };
    chip.load_rom(rom);

    chip.emulate_cycle();
}

test "expect chip8 to emulate opcode 1nnn" {
    var chip = chip8.init();
    const rom = &[_]u8{ 0x00, 0x01, 0x00, 0x01 };
    chip.load_rom(rom);

    chip.emulate_cycle();

    std.debug.print("pc: {any}\n", .{chip});
}
