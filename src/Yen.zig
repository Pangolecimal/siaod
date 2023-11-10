const std = @import("std");
const print = std.debug.print;

const Graph = @import("Graph.zig").Graph;
const Path = @import("BFS.zig").Path;
const bfs = @import("BFS.zig").bfs;

pub fn yen(graph: Graph, source: u32, target: usize, K: usize) !std.ArrayList(Path) {
    var A = std.ArrayList(Path).init(graph.allocator);
    defer A.deinit();
    var B = std.ArrayList(Path).init(graph.allocator);
    defer B.deinit();

    const shortestPath = try bfs(graph, source, target);
    try A.append(shortestPath);

    var i = 1;
    while (i < K) : (i += 1) {
        const spurNode = try findSpurNode(A.items[i - 1]);
        const rootPath = try findRootPath(A.items[i - 1], spurNode);
        _ = rootPath;
        const spurPath = try bfs(graph, source, spurNode);
        try B.append(spurPath);

        const minPath = try findMinPath(B);
        try A.append(minPath);
        B.items.len -= 1;
    }

    return A.clone();
}

fn findSpurNode(path: Path) !u32 {
    return path.nodes.items[1];
}

fn findRootPath(path: Path, spurNode: u32) !Path {
    var rootPath = Path.init(path.nodes.allocator);
    defer rootPath.deinit();

    for (path.nodes.items) |node| {
        if (node != spurNode) {
            try rootPath.nodes.append(node);
        }
    }

    return rootPath;
}

fn findMinPath(B: std.ArrayList(Path)) !Path {
    var minCost: u32 = std.math.maxInt(usize);
    var minPath: Path = undefined;

    for (B.items) |path| {
        if (path.cost < minCost) {
            minCost = path.cost;
            minPath = path;
        }
    }

    return minPath;
}
