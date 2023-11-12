const std = @import("std");
const log = std.debug.print;
const Graph = @import("Graph.zig").Graph;

pub const Path = struct {
    nodes: [Graph.NODE_AMOUNT]u32,

    pub fn init() Path {
        return Path{ .nodes = [_]u32{Graph.FILLER} ** Graph.NODE_AMOUNT };
    }

    pub fn append(self: *Path, node: u32) !void {
        if (node == Graph.FILLER) return;
        for (0..Graph.NODE_AMOUNT) |i| {
            if (self.nodes[i] != Graph.FILLER)
                if (i == Graph.NODE_AMOUNT - 1) return error.FULL_PATH else continue;

            self.nodes[i] = node;
            return;
        }
    }

    pub fn contains(self: Path, node: u32) bool {
        for (self.nodes) |n| {
            if (n == node) return true;
        }
        return false;
    }

    pub fn get_last(self: Path) ?u32 {
        var last_index: i32 = 0;
        for (self.nodes) |n| {
            if (n == Graph.FILLER) {
                last_index -= 1;
                break;
            }
            last_index += 1;
        }
        if (last_index == -1) return null;
        var idx: usize = @intCast(last_index);
        return if (last_index < Graph.NODE_AMOUNT) self.nodes[idx] else null;
    }

    pub fn clone(self: Path) !Path {
        var p = Path.init();
        for (self.nodes) |n| {
            if (n != Graph.FILLER) try p.append(n);
        }
        return p;
    }

    pub fn len(self: Path) u32 {
        var result: u32 = 0;
        for (self.nodes) |n| {
            if (n != Graph.FILLER) result += 1;
        }
        return result;
    }

    pub fn get_cost(self: Path, adj: Graph.ADJ_TYPE) u32 {
        var cost: u32 = 0;
        if (self.len() < 2) return 0;
        for (0..self.len() - 1) |i| {
            var curr = self.nodes[i];
            var next = self.nodes[i + 1];
            var weight = adj[curr][next];
            cost += weight;
        }
        return cost;
    }

    pub fn equal(self: Path, other: Path) bool {
        if (self.len() != other.len()) return false;
        for (self.nodes, 0..) |n, i| {
            if (n != other.nodes[i]) return false;
        }
        return true;
    }

    pub fn format(
        self: Path,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;

        try writer.print("Path: [", .{});

        if (self.nodes.len > 0)
            for (self.nodes) |n|
                if (n == Graph.FILLER)
                    try writer.print("× ", .{})
                else
                    try writer.print("{} ", .{n});

        try writer.writeAll("]");
    }
};

/// Breadth-First Search
pub fn bfs(graph: Graph, source: u32, target: u32) !Path {
    const AL = std.ArrayList;

    var queue: AL(Path) = AL(Path).init(graph.allocator);
    defer queue.deinit();

    var found: AL(Path) = AL(Path).init(graph.allocator);
    defer found.deinit();

    var first: Path = Path.init();
    try first.append(source);
    try queue.append(first);

    while (queue.items.len > 0) {
        // log("QUEUE:", .{});
        // for (queue.items) |path| {
        //     log(" {}", .{path});
        // }
        // log("\n", .{});

        var c_path: Path = queue.pop(); // current path

        // current node (last entry of current path)
        var c_node: u32 = undefined;
        if (c_path.get_last()) |_n| {
            c_node = _n;
        } else {
            continue; // path tried every node // impossible?
        }

        // log("\nFUCK\n\nQUEUE: {any}\n\nC_PATH: {}\n\nC_NODE: {}\n", .{ queue, c_path, c_node });

        // target is found
        if (c_node == target) {
            try found.append(c_path);
            continue;
        }

        // neighbouring nodes of the current node
        var n_nodes: AL(u32) = try graph.neighbors(c_node);

        // enqueue all neighbours that were not visited before
        for (n_nodes.items) |n| {
            // node `n` is already visited
            if (c_path.contains(n)) continue;

            var new_path = try c_path.clone();
            // log("\n  NEW PATH: {}    CURRENT PATH: {}\n\n", .{ new_path, c_path });
            try new_path.append(n);
            try queue.append(new_path);
        }
    }

    if (found.items.len == 0) return error.NotFound;

    // loop over `found` and return one with the lowest cost
    var min_cost: u32 = std.math.maxInt(u32);
    var min_cost_index: u32 = 0;
    for (found.items, 0..) |path, i| {
        var cost = path.get_cost(graph.adj);
        if (min_cost > cost) {
            min_cost = cost;
            min_cost_index = @truncate(i);
        }
    }

    log("BFS has found paths:\n", .{});
    for (found.items) |path| log("  {}\n", .{path});
    log("\n", .{});

    return found.items[min_cost_index];
}
