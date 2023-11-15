const std = @import("std");
const log = std.debug.print;

const Graph = @import("Graph.zig").Graph;
const Path = @import("BFS.zig").Path;
const bfs = @import("BFS.zig").bfs;

pub fn yen(graph: Graph, source: u32, target: u32, K: u32) !std.ArrayList(Path) {
    var A: std.ArrayList(Path) = std.ArrayList(Path).init(graph.allocator);
    defer A.deinit();
    var B: std.ArrayList(Path) = std.ArrayList(Path).init(graph.allocator);
    defer B.deinit();

    // Shortest path from source to target
    var shortest_path = (try bfs(graph, source, target)).items[0];
    try A.append(shortest_path);

    for (1..K) |k| {
        // The spur node ranges from the first node to the next to last node in the previous k-shortest path.
        var path = A.items[k - 1];

        for (0..path.len() - 2) |i| {
            var c_graph = graph; // Cloned graph

            // Spur node is retrieved from the previous k-shortest path, k − 1.
            var spur_node = path.nodes[i];

            // The sequence of nodes from the source to the spur node of the previous k-shortest path.
            var root_path = path.nodes[0..i];

            for (A.items) |p| {
                if (!std.mem.eql(u32, root_path, p.nodes[0..i])) continue;
                // Remove the links that are part of the previous shortest paths which share the same root path.
                c_graph.adj[i][i + 1] = Graph.FILLER;
            }

            // Calculate the spur path from the spur node to the sink.
            // Consider also checking if any spurPath found
            var spur_path: Path = (bfs(c_graph, spur_node, target) catch continue).items[0];

            // Entire path is made up of the root path and spur path.
            var total_path: Path = Path.init(graph.adj);
            for (root_path) |n| try total_path.append(n);
            for (spur_path.nodes) |n| try total_path.append(n);

            // Add the potential k-shortest path to the heap.
            var exists = for (B.items) |p| {
                if (total_path.equal(p)) break true;
            } else false;
            if (!exists)
                try B.append(total_path);
        }

        // This handles the case of there being no spur paths, or no spur paths left.
        // This could happen if the spur paths have already been exhausted (added to A),
        // or there are no spur paths at all - such as when both the source and sink vertices
        // lie along a "dead end".
        if (B.items.len == 0) break;
        sort(B); // Sort B by decreasing order of path cost
        try A.append(B.pop()); // Add the lowest cost path in B to A
    }
    return A.clone();
}

// Insertion sort for sorting paths by cost
fn sort(paths: std.ArrayList(Path)) void {
    for (1..paths.items.len) |i| {
        const key = paths.items[i];
        var j: isize = @intCast(i);
        j -= 1;
        while (j >= 0 and key.get_cost() > paths.items[@intCast(j)].get_cost()) : (j -= 1) {
            paths.items[@intCast(j + 1)] = paths.items[@intCast(j)];
        }
        paths.items[@intCast(j + 1)] = key;
    }
}
