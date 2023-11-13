const std = @import("std");
const log = std.debug.print;

pub const Graph = struct {
    ///Maximum number of nodes
    pub const NODE_AMOUNT = 256;

    ///Filler for "empty" cells
    pub const FILLER = std.math.maxInt(u32);

    ///DEBUG (not in production irreversably)
    pub const ADJ_TYPE = [NODE_AMOUNT][NODE_AMOUNT]u32;

    ///INTERNAL
    allocator: std.mem.Allocator,

    ///Number of nodes
    node_count: u32,

    ///Adjacency Matrix of the graph
    ///(only of size NODE_AMOUNT×NODE_AMOUNT, ArrayList is hard == skill issue)
    adj: ADJ_TYPE,

    pub fn init(allocator: std.mem.Allocator) !Graph {
        return Graph{
            .node_count = 0,
            .adj = [_][NODE_AMOUNT]u32{[_]u32{FILLER} ** NODE_AMOUNT} ** NODE_AMOUNT,
            .allocator = allocator,
        };
    }

    pub fn add_node(self: *Graph) !void {
        self.node_count += 1;
    }

    pub fn add_edge(self: *Graph, node_1_id: u32, node_2_id: u32, weight: u32) !void {
        self.adj[node_1_id][node_2_id] = weight;
        self.adj[node_2_id][node_1_id] = weight;
    }

    pub fn neighbors(self: Graph, node_id: u32) !std.ArrayList(u32) {
        var result = std.ArrayList(u32).init(self.allocator);
        defer result.deinit();

        for (self.adj[node_id], 0..) |weight, i| {
            if (weight != Graph.FILLER) {
                try result.append(@truncate(i));
            }
        }

        return result.clone();
    }

    ///When i wrote this God and I knew what was going on.
    ///Now only God knows...
    pub fn format(
        self: Graph,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt;
        _ = options;
        if (self.node_count == 0) @panic("Graph has no nodes");
        try writer.print("\n", .{});

        // log base 10 floored
        const log10 = std.math.log10_int;

        const node_length = log10(self.node_count);
        var max_len: u32 = @max(node_length, log10(@as(u32, NODE_AMOUNT)) + 1);
        for (&self.adj) |*row| {
            for (&row.*) |weight| {
                max_len = @max(max_len, if (weight == FILLER) max_len else log10(weight));
            }
        }

        for (&self.adj, 0..) |*row, i| {
            if (i == 0) continue;
            if (i > self.node_count) break;

            if (i == 1) {
                for (&row.*, 1..) |_, j| {
                    if (j > self.node_count) break;
                    const pad_len: usize = max_len - if (j > 0) log10(j) else 0;
                    const pad1_len: usize = node_length + 3 - if (i > 0) log10(i) else 0;

                    for (0..pad_len + if (j == 1) pad1_len else 0) |_| {
                        try writer.print(" ", .{});
                    }

                    try writer.print("{}", .{j});
                }
                try writer.print("\n", .{});
            }

            {
                const pad_len: usize = node_length + 2 - if (i > 0) log10(i) else 0;

                for (0..pad_len) |_| {
                    try writer.print(" ", .{});
                }

                try writer.print("{}", .{i});
            }

            for (&row.*, 0..) |weight, j| {
                if (j == 0) continue;
                if (j > self.node_count) break;
                const pad_len: usize = max_len - if (weight != FILLER) log10(weight) else 0;

                for (0..pad_len) |_| {
                    try writer.print("─", .{});
                }

                // ternary magic
                var grid_intersection = if (i < self.node_count)
                    if (j < self.node_count) "┼" else "┤"
                else if (j == self.node_count) "┘" else "┴";

                if (weight == FILLER) {
                    try writer.print("{s}", .{grid_intersection});
                } else {
                    try writer.print("{}", .{weight});
                }
            }
            try writer.print("\n", .{});
        }
        try writer.print("\n\n", .{});
    }
};
