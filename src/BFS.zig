const std = @import("std");
const print = std.debug.print;
const Graph = @import("Graph.zig").Graph;

pub const Path = struct {
    nodes: [Graph.NODE_AMOUNT]u32,

    pub fn init() Path {
        return Path{ .nodes = [_]u32{Graph.FILLER} ** Graph.NODE_AMOUNT };
    }

    pub fn append(self: *Path, node: u32) !void {
        for (0..Graph.NODE_AMOUNT) |i| {
            if (i == Graph.NODE_AMOUNT - 1) return error.FULL_PATH;
            if (self.nodes[i] != Graph.FILLER) continue;
            self.nodes[i] = node;
        }
    }

    pub fn contains(self: Path, node: u32) bool {
        for (self.nodes) |n| {
            if (n == node) return true;
        }
        return false;
    }

    pub fn get_last(self: Path) ?u32 {
        var last_index: u32 = 0;
        for (self.nodes) |n| {
            if (n != Graph.FILLER) last_index += 1;
        }
        return if (last_index < Graph.NODE_AMOUNT) self.nodes[last_index] else null;
    }

    pub fn clone(self: Path) !Path {
        var p = Path.init();
        for (self.nodes) |n| {
            if (n != Graph.FILLER) try p.append(n);
        }
        return p;
    }

    pub fn get_cost(self: Path, adj: Graph.ADJ_TYPE) u32 {
        _ = adj;
        _ = self;
        return 0;
    }
};

/// Breadth-First Search
pub fn bfs(graph: Graph, source: u32, target: u32, allocator: std.mem.Allocator) !Path {
    const AL = std.ArrayList;

    var queue = AL(*Path).init(allocator);
    defer queue.deinit();

    var found = AL(*Path).init(allocator);
    defer found.deinit();

    var first = Path.init();
    try first.append(source);
    try queue.append(&first);

    while (queue.items.len > 0) {
        var c_path = queue.pop(); // current path
        var c_node_nullable = c_path.get_last(); // current node (last entry of current path)
        if (c_node_nullable == null) continue; // path tried every node // impossible?
        var c_node = c_node_nullable.?;

        // target is found
        if (c_node == target) {
            try c_path.append(target);
            try found.append(c_path);
            continue;
        }

        // neighbouring nodes of the current node
        var n_nodes = AL(u32).init(allocator);
        defer n_nodes.deinit();
        for (graph.adj[c_node], 0..) |w, i| {
            if (w == Graph.FILLER) continue;
            var j: u32 = @truncate(i);
            try n_nodes.append(j);
        }

        for (n_nodes.items) |n| {
            // node `n` is already visited
            if (c_path.contains(n)) continue;

            var new_path = try c_path.clone();
            try new_path.append(n);
            try queue.append(&new_path);
        }
    }

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

    return found.items[min_cost_index].*;
}
