const std = @import("std");
const print = std.debug.print;
const Graph = @import("Graph.zig").Graph;

const Path = struct {
    nodes: std.ArrayList(usize),
    cost: usize,

    pub fn init(allocator: std.mem.Allocator) Path {
        return Path{
            .nodes = std.ArrayList(usize).init(allocator),
            .cost = 0,
        };
    }

    pub fn deinit(self: *Path) void {
        self.nodes.deinit();
    }

    pub fn append(self: *Path, node: usize) !void {
        try self.nodes.append(node);
    }

    pub fn cost(self: Path) usize {
        return self.cost;
    }
};

fn dijkstra(graph: Graph, source: usize, target: usize) !Path {
    var dist = [_]usize{0} ** 256;
    var prev = [_]usize{0} ** 256;
    var Q = [_]bool{false} ** 256;

    dist[source] = 0;
    for (&Q) |*q| {
        q.* = true;
    }

    while (true) {
        var u: usize = 0;
        for (Q, 0..) |q, i| {
            if (q and (dist[u] == 0 or dist[@as(usize, i)] < dist[u])) {
                u = @as(usize, i);
            }
        }
        Q[u] = false;

        if (u == target) {
            break;
        }

        for (0..graph.node_count) |v| {
            if (graph.adj[u][v] > 0 and Q[v]) {
                const alt = dist[u] + graph.adj[u][v];
                if (alt < dist[v]) {
                    dist[v] = alt;
                    prev[v] = u;
                }
            }
        }
    }

    var path = Path.init(graph.allocator);
    var u: usize = target;
    while (u != source) {
        try path.nodes.append(u);
        u = prev[u];
    }
    try path.nodes.append(source);
    std.mem.reverse(usize, path.nodes.items);
    path.cost = dist[target];
    return path;
}

pub fn yen(graph: Graph, source: usize, target: usize, K: usize) !std.ArrayList(Path) {
    var A = std.ArrayList(Path).init(graph.allocator);
    defer A.deinit();
    var B = std.ArrayList(Path).init(graph.allocator);
    defer B.deinit();

    const shortestPath = try dijkstra(graph, source, target);
    try A.append(shortestPath);

    var i: usize = 1;
    while (i < K) : (i += 1) {
        const spurNode = try findSpurNode(A.items[i - 1]);
        const rootPath = try findRootPath(A.items[i - 1], spurNode);
        _ = rootPath;
        const spurPath = try dijkstra(graph, source, spurNode);
        try B.append(spurPath);

        const minPath = try findMinPath(B);
        try A.append(minPath);
        B.items.len -= 1;
    }

    return A.clone();
}

fn findSpurNode(path: Path) !usize {
    return path.nodes.items[1];
}

fn findRootPath(path: Path, spurNode: usize) !Path {
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
    var minCost: usize = std.math.maxInt(usize);
    var minPath: Path = undefined;

    for (B.items) |path| {
        if (path.cost < minCost) {
            minCost = path.cost;
            minPath = path;
        }
    }

    return minPath;
}
