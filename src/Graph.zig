const std = @import("std");
const print = std.debug.print;

pub const Graph = struct {
    ///Maximum number of nodes
    pub const NODE_AMOUNT = 32;

    ///Filler for "empty" cells
    pub const FILLER = std.math.maxInt(u32);

    ///DEBUG
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

    ///When i wrote this God and I knew what was going on.
    ///Now only God knows...
    pub fn print_graph(self: Graph) !void {
        if (self.node_count == 0) @panic("Graph has 0 nodes");

        // log base 10 floored
        const log = std.math.log10_int;

        const node_length = log(self.node_count);
        var max_len: u32 = @max(node_length, log(@as(u32, NODE_AMOUNT)) + 1);
        for (&self.adj) |*row| {
            for (&row.*) |weight| {
                max_len = @max(max_len, if (weight == FILLER) max_len else log(weight));
            }
        }

        for (&self.adj, 0..) |*row, i| {
            if (i > self.node_count) break;

            if (i == 0) {
                for (&row.*, 0..) |_, j| {
                    if (j > self.node_count) break;
                    const pad_len: usize = max_len - if (j > 0) log(j) else 0;
                    const pad1_len: usize = node_length + 1 - if (i > 0) log(i) else 0;

                    var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                    defer padding.deinit();
                    for (0..pad_len + if (j == 0) pad1_len else 0) |_| {
                        try padding.append(' ');
                    }

                    print("{s}{}", .{ padding.items, j });
                }
                print("\n", .{});
            }

            {
                const pad_len: usize = node_length - if (i > 0) log(i) else 0;

                var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                defer padding.deinit();
                for (0..pad_len) |_| {
                    try padding.append(' ');
                }

                print("{s}{}", .{ padding.items, i });
            }

            for (&row.*, 0..) |weight, j| {
                if (j > self.node_count) break;
                const pad_len: usize = max_len - if (weight != FILLER) log(weight) else 0;

                var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                defer padding.deinit();
                for (0..pad_len) |_| {
                    try padding.appendSlice("─");
                }

                print("{s}", .{padding.items});

                // ternary magic
                var grid_intersection = if (i < self.node_count)
                    if (j < self.node_count) "┼" else "┤"
                else if (j == self.node_count) "┘" else "┴";

                if (weight == FILLER) {
                    print("{s}", .{grid_intersection});
                } else {
                    print("{}", .{weight});
                } //×
            }
            print("\n", .{});
        }
        print("\n\n", .{});
    }
};
