const std = @import("std");
const print = std.debug.print;

const Graph = @import("Graph.zig").Graph;
const Path = @import("BFS.zig").Path;

const bfs = @import("BFS.zig").bfs;
const yen = @import("Yen.zig");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var graph = try Graph.init(allocator);
    // defer graph.deinit();

    for (1..10) |_| try graph.add_node();
    try graph.add_edge(0, 1, 1);
    try graph.add_edge(1, 2, 2);

    try graph.print_graph();

    _ = try bfs(graph, 0, 1, allocator);

    print("\n", .{});

    // const paths = try yen.yen(graph, 0, 2, 3);
    // for (paths.items) |*path| {
    //     print("Path: ", .{});
    //     for (path.nodes.items) |node| {
    //         print("{} ", .{node});
    //     }
    //     print("\n", .{});
    // }
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
