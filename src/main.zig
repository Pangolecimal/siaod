const std = @import("std");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    var graph = Graph.init(allocator);

    // Add nodes
    try graph.addNode(1);
    try graph.addNode(2);
    try graph.addNode(3);
    try graph.addNode(4);

    // Add edges
    try graph.addEdge(0, 1, 5);
    try graph.addEdge(1, 2, 3);
    try graph.addEdge(2, 3, 7);
    try graph.addEdge(3, 0, 2);

    // Print graph
    graph.printGraph();
}

const Node = struct {
    value: u32,
    edges: std.ArrayList(Edge),
};

const Edge = struct {
    node: *Node,
    weight: u32,
};

const Graph = struct {
    const AL = std.ArrayList;
    nodes: AL(Node),
    // adj_mat: AL(AL(u32)),

    pub fn init(allocator: std.mem.Allocator) Graph {
        return Graph{ .nodes = AL(Node).init(allocator) };
    }

    pub fn addNode(self: *Graph, value: u32) !void {
        const node = Node{ .value = value, .edges = AL(Edge).init(self.nodes.allocator) };
        try self.nodes.append(node);
    }

    pub fn addEdge(self: *Graph, node1: u32, node2: u32, weight: u32) !void {
        const edge1 = Edge{ .node = &self.nodes.items[node2], .weight = weight };
        const edge2 = Edge{ .node = &self.nodes.items[node1], .weight = weight };
        try self.nodes.items[node1].edges.append(edge1);
        try self.nodes.items[node2].edges.append(edge2);
    }

    pub fn printGraph(self: Graph) void {
        for (self.nodes.items) |node| {
            std.debug.print("Node {}: ", .{node.value});
            for (node.edges.items) |edge| {
                std.debug.print("{} ({}), ", .{ edge.node.value, edge.weight });
            }
            std.debug.print("\n", .{});
        }
    }
};

// Graph 7:
// nodes: 1 2 3 4 5 6 7 8
// adjacency matrix:
//    1  2  3  4  5  6  7  8
// 1: 0  |  |  |  |  |  |  |
// 2: 23 0  |  |  |  |  |  |
// 3: 12 25 |  |  |  |  |  |
// 4: 0  0  18 0  |  |  |  |
// 5: 0  22 0  0  0  |  |  |
// 6: 0  0  0  20 23 0  |  |
// 7: 0  0  0  0  14 24 0  |
// 8: 0  35 0  0  0  0  16 0
