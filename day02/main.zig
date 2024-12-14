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
    const data =
        \\ 7 6 4 2 1
        \\ 1 2 7 8 9
        \\ 9 7 6 2 1
        \\ 1 3 2 4 5
        \\ 8 6 4 4 1
        \\ 1 3 6 7 9
    ;
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(4, try part2(data, allocator));
}

// --------- IMPLEMENTATION ---------
pub fn part1(data: []const u8, allocator: std.mem.Allocator) !i32 {
    var acc: i32 = 0;
    var line_iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_iter.next()) |line| {
        var report = std.ArrayList(i32).init(allocator);
        defer report.deinit();

        var token_iter = std.mem.tokenizeScalar(u8, line, ' ');
        while (token_iter.next()) |token| {
            const number = try std.fmt.parseInt(i32, token, 10);

            try report.append(number);
        }

        if (is_safe(report.items)) acc += 1;
    }

    return acc;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !i32 {
    var acc: i32 = 0;
    var line_iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_iter.next()) |line| {
        var report = std.ArrayList(i32).init(allocator);
        defer report.deinit();

        var token_iter = std.mem.tokenizeScalar(u8, line, ' ');
        while (token_iter.next()) |token| {
            const number = try std.fmt.parseInt(i32, token, 10);

            try report.append(number);
        }

        if (is_safe_with_removal(report.items, allocator)) acc += 1;
    }

    return acc;
}

// --------- HELPERS ---------
pub fn is_safe_with_removal(report: []const i32, allocator: std.mem.Allocator) bool {
    if (is_safe(report)) return true;

    const slice = allocator.alloc(i32, report.len - 1) catch undefined;
    defer allocator.free(slice);

    for (0..report.len) |ignore_index| {
        for (report, 0..) |level, index| {
            const slice_index = if (ignore_index < index) index - 1 else index;
            if (ignore_index != index) slice[slice_index] = level;
        }

        if (is_safe(slice)) return true;
    }

    return false;
}

pub fn is_safe(report: []const i32) bool {
    const Ordering = enum { asc, desc };

    var last_level_opt: ?i32 = null;
    var ordering_opt: ?Ordering = null;

    for (report) |level| {
        defer last_level_opt = level;

        // do nothing for first level
        const last_level = last_level_opt orelse continue;

        // set ordering if it is not set yet
        if (ordering_opt == null) {
            ordering_opt = if (last_level < level) Ordering.asc else Ordering.desc;
        }
        const ordering = ordering_opt orelse undefined;

        // compute the allowed range for the current number
        const min = switch (ordering) {
            .asc => last_level + 1,
            .desc => last_level - 3,
        };
        const max = switch (ordering) {
            .asc => last_level + 3,
            .desc => last_level - 1,
        };

        // if it is out of range, the ordering is unsatisfied
        if (level > max or level < min) return false;
    }

    return last_level_opt != null;
}
