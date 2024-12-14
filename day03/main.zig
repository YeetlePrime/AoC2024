const std = @import("std");

// --------- MAIN ---------
pub fn main() !void {
    const data = @embedFile("input.txt");

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const part1_solution = try part1(data, allocator);
    const part2_solution = try part2(data, allocator);

    std.debug.print("Part1: {d}\n", .{part1_solution});
    std.debug.print("Part2: {d}\n", .{part2_solution});
}

// --------- TESTS ---------
test "Part 1" {
    const data = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))";
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(161, try part1(data, allocator));
}

test "Part 2" {
    const data = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))";
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(0, try part2(data, allocator));
}

// --------- IMPLEMENTATION ---------
pub fn part1(data: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = allocator;

    var acc: i32 = 0;
    var iter = SliceIterator(u8).init(data);
    while (iter.next()) |character| {
        if (character == 'm') {
            if (iter.peek() != 'u') continue;
            iter.consume();

            if (iter.peek() != 'l') continue;
            iter.consume();

            if (iter.peek() != '(') continue;
            iter.consume();

            // find first number
            var c = iter.peek() orelse ' ';
            if (!is_a_number(c)) continue;
            var first_number: i32 = 0;
            while (is_a_number(c)) {
                defer {
                    iter.consume();
                    c = iter.peek() orelse ' ';
                }

                first_number = first_number * 10 + @as(i32, c - '0');
            }
            if (first_number > 999) continue;

            if (iter.peek() != ',') continue;
            iter.consume();

            // find second number
            c = iter.peek() orelse ' ';
            if (!is_a_number(c)) continue;
            var second_number: i32 = 0;
            while (is_a_number(c)) {
                defer {
                    iter.consume();
                    c = iter.peek() orelse ' ';
                }

                second_number = second_number * 10 + @as(i32, c - '0');
            }
            if (second_number > 999) continue;

            if (iter.peek() != ')') continue;
            iter.consume();

            acc += first_number * second_number;
        }
    }

    return acc;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = data;
    _ = allocator;

    return -1;
}

// --------- HELPERS ---------
pub fn SliceIterator(comptime T: type) type {
    return struct {
        const Self = @This();
        data: []const T,
        index: usize,

        pub fn init(data: []const T) Self {
            return Self{
                .data = data,
                .index = 0,
            };
        }

        pub fn next(self: *Self) ?T {
            if (self.index >= self.data.len) return null;

            const element = self.data[self.index];
            self.index += 1;
            return element;
        }

        pub fn peek(self: *Self) ?T {
            if (self.index >= self.data.len) return null;

            return self.data[self.index];
        }

        pub fn consume(self: *Self) void {
            if (self.index < self.data.len) self.index += 1;
        }
    };
}

pub fn is_a_number(character: u8) bool {
    return '0' <= character and character <= '9';
}
