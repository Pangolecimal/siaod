const std = @import("std");
const log = std.debug.print;

const Graph = @import("Graph.zig").Graph;
const Path = @import("BFS.zig").Path;

const bfs = @import("BFS.zig").bfs;
const yen = @import("Yen.zig").yen;

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var graph = try Graph.init(allocator);
    // defer graph.deinit();

    for (1..5) |_| try graph.add_node();
    try graph.add_edge(0, 1, 1);
    try graph.add_edge(1, 2, 2);
    try graph.add_edge(1, 3, 3);
    try graph.add_edge(2, 4, 4);
    try graph.add_edge(2, 5, 6);
    try graph.add_edge(3, 4, 5);
    try graph.add_edge(4, 5, 7);

    log("{}", .{graph});
    log("bfs: {any}", .{bfs(graph, 0, 3)});
    log("\n", .{});

    // var ksp = try yen(graph, 0, 3, 3);
    // log("\nksp: {any}\n\n", .{ksp});
    // for (ksp.items) |path| {
    //     log("YEN: {}\n", .{path});
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
