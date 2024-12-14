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
    const data =
        \\ 7 6 4 2 1
        \\ 1 2 7 8 9
        \\ 9 7 6 2 1
        \\ 1 3 2 4 5
        \\ 8 6 4 4 1
        \\ 1 3 6 7 9
    ;

    const allocator = std.testing.allocator;

    try std.testing.expectEqual(2, try part1(data, allocator));
}

test "Part 2" {
    const data = "";
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(0, try part2(data, allocator));
}

// --------- IMPLEMENTATION ---------
pub fn part1(data: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = data;
    _ = allocator;

    return -1;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = data;
    _ = allocator;

    return -1;
}

// --------- HELPERS ---------
