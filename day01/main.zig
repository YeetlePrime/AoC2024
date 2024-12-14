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
        \\ 3   4
        \\ 4   3
        \\ 2   5
        \\ 1   3
        \\ 3   9
        \\ 3   3
    ;

    const allocator = std.testing.allocator;

    try std.testing.expectEqual(11, try part1(data, allocator));
}

test "Part 2" {
    const data =
        \\ 3   4
        \\ 4   3
        \\ 2   5
        \\ 1   3
        \\ 3   9
        \\ 3   3
    ;
    const allocator = std.testing.allocator;

    try std.testing.expectEqual(31, try part2(data, allocator));
}

// --------- IMPLEMENTATION ---------
pub fn part1(data: []const u8, allocator: std.mem.Allocator) !i32 {
    var left_list = std.ArrayList(i32).init(allocator);
    var right_list = std.ArrayList(i32).init(allocator);

    defer left_list.deinit();
    defer right_list.deinit();

    var line_iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_iter.next()) |line| {
        var token_iter = std.mem.tokenizeScalar(u8, line, ' ');

        const left_token = token_iter.next() orelse undefined;
        const right_token = token_iter.next() orelse undefined;

        const left_number = try std.fmt.parseInt(i32, left_token, 10);
        const right_number = try std.fmt.parseInt(i32, right_token, 10);

        try left_list.append(left_number);
        try right_list.append(right_number);
    }

    std.mem.sort(i32, left_list.items, {}, std.sort.asc(i32));
    std.mem.sort(i32, right_list.items, {}, std.sort.asc(i32));

    var acc: i32 = 0;
    for (left_list.items, right_list.items) |left, right| {
        acc += distance(left, right);
    }

    return acc;
}

pub fn part2(data: []const u8, allocator: std.mem.Allocator) !i32 {
    var left_numbers = std.ArrayList(i32).init(allocator);
    defer left_numbers.deinit();

    var occurences = std.AutoHashMap(i32, i32).init(allocator);
    defer occurences.deinit();

    var line_iter = std.mem.tokenizeScalar(u8, data, '\n');
    while (line_iter.next()) |line| {
        var token_iter = std.mem.tokenizeScalar(u8, line, ' ');

        const left_token = token_iter.next() orelse undefined;
        const right_token = token_iter.next() orelse undefined;

        const left_number = try std.fmt.parseInt(i32, left_token, 10);
        const right_number = try std.fmt.parseInt(i32, right_token, 10);

        try left_numbers.append(left_number);
        try occurences.put(right_number, (occurences.get(right_number) orelse 0) + 1);
    }

    var acc: i32 = 0;
    for (left_numbers.items) |number| {
        acc += number * (occurences.get(number) orelse 0);
    }

    return acc;
}

// --------- HELPERS ---------
pub fn distance(left: i32, right: i32) i32 {
    return if (left > right) left - right else right - left;
}
