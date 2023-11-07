const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var G = try Graph.init(allocator);
    // adds N nodes
    for (1..20) |_| {
        try G.add_node();
    }
    try G.add_edge(0, 2, 100);
    try G.add_edge(2, 6, 200);
    try G.add_edge(18, 19, 1000);
    try G.print_graph();

    // // Add nodes
    // try graph.add_node(1);
    // try graph.add_node(2);
    // try graph.add_node(3);
    // try graph.add_node(4);
    //
    // // Add edges
    // try graph.add_edge(0, 1, 5);
    // try graph.add_edge(1, 2, 3);
    // try graph.add_edge(2, 3, 7);
    // try graph.add_edge(3, 0, 2);
    //
    // // Print graph
    // graph.print();
}

const Graph = struct {
    ///INTERNAL
    allocator: std.mem.Allocator,

    ///A list of all the nodes
    node_count: u32,

    ///Adjacency Matrix of the graph
    ///(currently of size <= 256x256, completely a skill issue)
    adj: [256][256]u32,

    pub fn init(allocator: std.mem.Allocator) !Graph {
        var G = Graph{
            .node_count = 0,
            .adj = [_][256]u32{[_]u32{0} ** 256} ** 256,
            .allocator = allocator,
        };

        // for (&G.adj) |*row| {
        //     for (&row.*) |*item| {
        //         item.* = 0;
        //     }
        // }

        return G;
    }

    ///Adds a new empty node and assigns it a unique index
    ///(starts at 0 and increases with every new node)
    pub fn add_node(self: *Graph) !void {
        self.node_count += 1;
    }

    pub fn add_edge(self: *Graph, node_1_id: u32, node_2_id: u32, weight: u32) !void {
        self.adj[node_1_id][node_2_id] = weight;
        self.adj[node_2_id][node_1_id] = weight;
    }

    pub fn print_graph(self: Graph) !void {
        if (self.node_count == 0) @panic("Graph has 0 nodes");

        const node_length = std.math.log10_int(self.node_count);
        var max_len: u32 = @max(node_length, 0); // 3 because 256
        for (&self.adj) |*row| {
            for (&row.*) |weight| {
                if (weight <= 0) continue;
                max_len = @max(max_len, std.math.log10_int(weight));
            }
        }

        for (&self.adj, 0..) |*row, i| {
            if (i > self.node_count) break;

            if (i == 0) {
                for (&row.*, 0..) |_, j| {
                    if (j > self.node_count) break;
                    const pad_len: usize = max_len + 1 - if (j > 0) std.math.log10_int(j) else 0;
                    const pad1_len: usize = node_length + 3 - if (i > 0) std.math.log10_int(i) else 0;

                    var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                    defer padding.deinit();
                    for (0..pad_len + if (j == 0) pad1_len else 0) |_| {
                        try padding.append(' ');
                    }

                    print("{s}{}", .{ padding.items, j });
                }
                print("\n\n", .{});
            }

            {
                const pad_len: usize = node_length + 1 - if (i > 0) std.math.log10_int(i) else 0;

                var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                defer padding.deinit();
                for (0..pad_len) |_| {
                    try padding.append(' ');
                }

                print("{}:{s}", .{ i, padding.items });
            }

            for (&row.*, 0..) |weight, j| {
                if (j > self.node_count) break;
                const pad_len: usize = max_len + 1 - if (weight > 0) std.math.log10_int(weight) else 0;

                var padding = try std.ArrayList(u8).initCapacity(self.allocator, pad_len);
                defer padding.deinit();
                for (0..pad_len) |_| {
                    try padding.append(' ');
                }

                print("{s}{}", .{ padding.items, weight });
            }
            print("\n", .{});
        }
    }
};

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
