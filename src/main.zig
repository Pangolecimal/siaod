const std = @import("std");
const log = std.debug.print;
const eql = std.mem.eql;

const Graph = @import("Graph.zig").Graph;
const Path = @import("BFS.zig").Path;

const bfs = @import("BFS.zig").bfs;
const yen = @import("Yen.zig").yen;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    var buffer: [64]u8 = undefined;
    var mode: usize = 0;

    try stdout.writeAll("Input the creation mode ([m]anual or [a]utomatic): ");
    const input_mode = (try nextLine(stdin.reader(), &buffer)).?;

    if (eql(u8, input_mode, "m")) {
        try stdout.writeAll("  Manual Mode.\n");
        mode = 1;
    } else if (eql(u8, input_mode, "a")) {
        try stdout.writeAll("  Automatic Mode.\n");
        mode = 2;
    } else {
        try stdout.writeAll("  Invalid.\n");
        @panic("INVALID INPUT MODE");
    }

    var graph = try Graph.init(allocator);
    switch (mode) {
        1 => {
            // Manual
            try stdout.writeAll("  Input the number of nodes: ");
            const input_num_nodes = (try nextLine(stdin.reader(), &buffer)).?;
            const num_nodes = try std.fmt.parseUnsigned(u32, input_num_nodes, 10);
            for (0..num_nodes) |_| try graph.add_node();

            while (true) {
                try stdout.writeAll("  Input an edge ([source target weight] or [e]xit): ");
                const input_edge = (try nextLine(stdin.reader(), &buffer)).?;
                if (eql(u8, input_edge, "e")) break;

                var num_spaces: u32 = 0;
                for (input_edge) |ch| {
                    if (ch == ' ') num_spaces += 1;
                }
                if (num_spaces != 2) {
                    try stdout.writer().print(
                        "E: INVALID EDGE FORMAT (EXPECTED: `source target weight` GOT: {s})\n\n",
                        .{input_edge},
                    );
                    continue;
                }

                var iter = std.mem.split(u8, input_edge, " ");
                const source = try std.fmt.parseUnsigned(u32, iter.next().?, 10);
                const target = try std.fmt.parseUnsigned(u32, iter.next().?, 10);
                const weight = try std.fmt.parseUnsigned(u32, iter.next().?, 10);

                if (source > num_nodes) {
                    try stdout.writer().print(
                        "E: INVALID NODE NUMBER ({} is bigger than {})\n\n",
                        .{ source, num_nodes },
                    );
                    continue;
                }
                if (target > num_nodes) {
                    try stdout.writer().print(
                        "E: INVALID NODE NUMBER ({} is bigger than {})\n\n",
                        .{ target, num_nodes },
                    );
                    continue;
                }

                try graph.add_edge(source, target, weight);
                try stdout.writer().print("    Successfully added an edge {} between {} and {}\n\n", .{ weight, source, target });
            }
        },
        2 => {
            // Automatic
            for (1..9) |_| try graph.add_node();
            try graph.add_edge(1, 2, 23);
            try graph.add_edge(1, 3, 12);
            try graph.add_edge(2, 3, 25);
            try graph.add_edge(2, 5, 22);
            try graph.add_edge(2, 8, 35);
            try graph.add_edge(3, 4, 18);
            try graph.add_edge(4, 6, 20);
            try graph.add_edge(5, 6, 23);
            try graph.add_edge(5, 7, 14);
            try graph.add_edge(6, 7, 24);
            try graph.add_edge(7, 8, 16);
        },
        else => {
            try stdout.writeAll("  What the hell are ya doin?\n");
            unreachable;
        },
    }

    log("\nGraph's Adjacency Matrix:{}", .{graph});

    // input source, target and K
    try stdout.writer().print("Input the SOURCE node (1..{}): ", .{graph.node_count});
    const input_source = (try nextLine(stdin.reader(), &buffer)).?;
    const source = try std.fmt.parseUnsigned(u32, input_source, 10);

    try stdout.writer().print("Input the TARGET node (1..{}): ", .{graph.node_count});
    const input_target = (try nextLine(stdin.reader(), &buffer)).?;
    const target = try std.fmt.parseUnsigned(u32, input_target, 10);

    try stdout.writeAll("Input K (amount of shortest paths to find): ");
    const input_K = (try nextLine(stdin.reader(), &buffer)).?;
    const K = try std.fmt.parseUnsigned(u32, input_K, 10);

    try stdout.writer().print("\nFound:\n", .{});
    var result = bfs(graph, source, target) catch null;
    if (result != null) for (result.?.items, 0..) |path, i| {
        if (i < K) try stdout.writer().print("  {}\n", .{path});
    };
    try stdout.writer().print("\n", .{});

    // // never got it working, idk why. wiki pseudo code has failed me once again.
    // var ksp = try yen(graph, 1, 8, 2);
    // // log("\nksp: {any}\n\n", .{ksp});
    // log("YEN found:\n", .{});
    // for (ksp.items) |path| {
    //     log("  {}\n", .{path});
    // }
}

fn nextLine(reader: anytype, buffer: []u8) !?[]const u8 {
    var line = (try reader.readUntilDelimiterOrEof(
        buffer,
        '\n',
    )) orelse return null;
    // trim annoying windows-only carriage return character
    if (@import("builtin").os.tag == .windows) {
        return std.mem.trimRight(u8, line, "\r");
    } else {
        return line;
    }
}

// Graph 7:
// nodes: 1 2 3 4 5 6 7 8
// adjacency matrix: [ (i,j) == (j,i) ]
//    1  2  3  4  5  6  7  8
// 1: 0  |  |  |  |  |  |  |
// 2: 23 0  |  |  |  |  |  |
// 3: 12 25 0  |  |  |  |  |
// 4: 0  0  18 0  |  |  |  |
// 5: 0  22 0  0  0  |  |  |
// 6: 0  0  0  20 23 0  |  |
// 7: 0  0  0  0  14 24 0  |
// 8: 0  35 0  0  0  0  16 0
