const std = @import("std");

pub fn init() Chip8 {
    var chip = Chip8{};
    chip.load_fontset();
    return chip;
}

const fontset: [80]u8 = .{
    0xF0, 0x90, 0x90, 0x90, 0xF0, // 0
    0x20, 0x60, 0x20, 0x20, 0x70, // 1
    0xF0, 0x10, 0xF0, 0x80, 0xF0, // 2
    0xF0, 0x10, 0xF0, 0x10, 0xF0, // 3
    0x90, 0x90, 0xF0, 0x10, 0x10, // 4
    0xF0, 0x80, 0xF0, 0x10, 0xF0, // 5
    0xF0, 0x80, 0xF0, 0x90, 0xF0, // 6
    0xF0, 0x10, 0x20, 0x40, 0x40, // 7
    0xF0, 0x90, 0xF0, 0x90, 0xF0, // 8
    0xF0, 0x90, 0xF0, 0x10, 0xF0, // 9
    0xF0, 0x90, 0xF0, 0x90, 0x90, // A
    0xE0, 0x90, 0xE0, 0x90, 0xE0, // B
    0xF0, 0x80, 0x80, 0x80, 0xF0, // C
    0xE0, 0x90, 0x90, 0x90, 0xE0, // D
    0xF0, 0x80, 0xF0, 0x80, 0xF0, // E
    0xF0, 0x80, 0xF0, 0x80, 0x80, // F
};

pub const Chip8Error = error{
    InvalidOpcode,
    Unimplemented,
};

pub const Opcodes = union(enum) {
    _00e0: void,
    _00ee: void,
    _1nnn: struct { u16 },
    _2nnn: struct { u16 },
    _3xnn: struct { u8, u8 },
    _4xnn: struct { u8, u8 },
    _5xyo: struct { u8, u8 },
    _6xnn: struct { u8, u8 },
    _7xnn: struct { u8, u8 },
    _8xy0: struct { u8, u8 },
    _8xy1: struct { u8, u8 },
    _8xy2: struct { u8, u8 },
    _8xy3: struct { u8, u8 },
    _8xy4: struct { u8, u8 },
    _8xy5: struct { u8, u8 },
    _8xy6: struct { u8, u8 },
    _8xy7: struct { u8, u8 },
    _8xy8: struct { u8, u8 },
    _8xy9: struct { u8, u8 },
    _8xye: struct { u8, u8 },
    _9xy0: struct { u8, u8 },
    _Annn: struct { u16 },
    _Bnnn: struct { u16 },
    _Cxnn: struct { u8, u8 },
    _Dxyn: struct { u8, u8, u8 },
    _Ex9e: struct { u8 },
    _Exa1: struct { u8 },
    _Fx07: struct { u8 },
    _Fx0a: struct { u8 },
    _Fx15: struct { u8 },
    _Fx18: struct { u8 },
    _Fx1e: struct { u8 },
    _Fx29: struct { u8 },
    _Fx33: struct { u8 },
    _Fx55: struct { u8 },
    _Fx65: struct { u8 },
    _: void,

    pub fn get_hex_opcode(hex: u16) !Opcodes {
        const nnn: u16 = hex & 0x0FFF;
        const nn: u16 = hex & 0x00FF;
        _ = nn; // autofix
        const op = (hex & 0xF000) >> 12;
        const op_x = (hex & 0x0F00) >> 8;
        _ = op_x; // autofix
        const op_y = (hex & 0x00F0) >> 4;
        _ = op_y; // autofix

        std.debug.print("Getting hex opcode of {any} — op: {any}\n", .{ hex, op });

        return switch (op) {
            0x00 => validate_initial_opcodes(hex),
            0x1 => Opcodes{ ._1nnn = .{nnn} },
            else => error.InvalidOpcode,
        };
    }

    fn validate_initial_opcodes(hex: u16) !Opcodes {
        return switch (hex & 0x00FF) {
            0x00E0 => Opcodes{ ._00e0 = {} },
            0x00EE => Opcodes{ ._00ee = {} },
            else => error.InvalidOpcode,
        };
    }
};

const StartAddress: comptime_int = 0x200;
const FontSetStartAddress: comptime_int = 0x50;
const OpcodeSize = 2;

pub const Chip8 = struct {
    pc: u16 = StartAddress,
    sp: u8 = 0,
    memory: [4096]u8 = undefined,
    stack: [16]u16 = undefined,

    pub fn load_rom(self: *Chip8, rom: []const u8) void {
        std.mem.copyForwards(u8, self.memory[StartAddress..], rom);
    }

    fn load_fontset(self: *Chip8) void {
        std.mem.copyForwards(u8, self.memory[FontSetStartAddress..], &fontset);
    }

    pub fn emulate_cycle(self: *Chip8) void {
        const opcode = self.fetch_and_decode() catch {
            @panic("Error: invalid opcode");
        };

        self.run_instruction(opcode) catch {
            @panic("Error: faield to run instruction");
        };
    }

    fn fetch_and_decode(self: *Chip8) !Opcodes {
        const hi: u16 = self.memory[self.pc];
        const lo: u16 = self.memory[self.pc + 1];
        const hex_op = hi << 8 | lo;
        return Opcodes.get_hex_opcode(hex_op) catch |err| {
            std.debug.print("err: {any}\n", .{err});
            return err;
        };
    }

    fn run_instruction(self: *Chip8, opcode: Opcodes) !void {
        std.debug.print("Running instruction: {any}\n", .{opcode});
        switch (opcode) {
            ._00e0 => {
                self.pc += OpcodeSize;
            },
            ._00ee => {
                self.sp -= 1;
                const addr = self.stack[self.sp];
                self.pc = addr;
                self.pc += OpcodeSize;
            },
            ._1nnn => {
                const nnn = opcode._1nnn[0];
                self.pc = nnn;
            },
            else => {
                return error.Unimplemented;
            },
        }
    }
};
