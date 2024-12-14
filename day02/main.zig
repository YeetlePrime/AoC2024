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
    _ = allocator;

    var acc: i32 = 0;
    var report_iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (report_iter.next()) |report| {
        if (try is_safe(report)) acc += 1;
    }

    return acc;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !i32 {
    _ = data;
    _ = allocator;

    return -1;
}

// --------- HELPERS ---------
pub fn is_safe(report: []const u8) !bool {
    const Ordering = enum { asc, desc };
    var token_iter = std.mem.tokenizeScalar(u8, report, ' ');

    var last_number_opt: ?i32 = null;
    var ordering_opt: ?Ordering = null;

    while (token_iter.next()) |token| {
        const number = try std.fmt.parseInt(i32, token, 10);
        defer last_number_opt = number;

        // do nothing for first number
        const last_number = last_number_opt orelse continue;

        // set ordering if it is not set yet
        if (ordering_opt == null) {
            ordering_opt = if (last_number < number) Ordering.asc else Ordering.desc;
        }
        const ordering = ordering_opt orelse undefined;

        // compute the allowed range for the current number
        const min = switch (ordering) {
            .asc => last_number + 1,
            .desc => last_number - 3,
        };
        const max = switch (ordering) {
            .asc => last_number + 3,
            .desc => last_number - 1,
        };

        // if it is out of range, the ordering is unsatisfied
        if (number > max or number < min) return false;
    }

    return last_number_opt != null;
}
