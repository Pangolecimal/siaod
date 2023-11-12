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
    var shortest_path = try bfs(graph, source, target);
    try A.append(shortest_path);

    for (1..K) |k| {
        // The spur node ranges from the first node to the next to last node in the previous k-shortest path.
        var path = A.items[k - 1];
        for (0..path.len() - 2) |i| {
            // Spur node is retrieved from the previous k-shortest path, k − 1.
            var spur_node = path.nodes[i];

            // The sequence of nodes from the source to the spur node of the previous k-shortest path.
            var root_path = path.nodes[0..i];

            // Clone the adjacency matrix
            var c_graph = graph;
            // log("LOL {}\n", .{c_graph});

            for (A.items) |p| {
                var equal = root_path.len == p.nodes[0..i].len;
                if (!equal) continue;

                for (root_path, 0..) |_node, _i| {
                    if (_node != p.nodes[_i]) {
                        equal = false;
                        break;
                    }
                }
                if (!equal) continue;

                // Remove the links that are part of the previous shortest paths which share the same root path.
                c_graph.adj[i][i + 1] = Graph.FILLER;
            }

            for (root_path) |root_path_node| {
                if (root_path_node == spur_node) continue;
                c_graph.adj[root_path_node] = Graph.FILLER_ROW;
            }

            // Calculate the spur path from the spur node to the sink.
            // Consider also checking if any spurPath found
            var spur_path: Path = bfs(graph, spur_node, target) catch {
                // log("FUCK: {} {}", .{ spur_node, target });
                continue;
            };

            // Entire path is made up of the root path and spur path.
            var total_path: Path = Path.init();
            for (root_path) |n| try total_path.append(n);
            for (spur_path.nodes) |n| try total_path.append(n);

            // log("HAHA {}\n", .{total_path});
            // Add the potential k-shortest path to the heap.
            // var exists = for (B.items) |p| {
            //     if (total_path.equal(p)) break true;
            // } else false;
            // if (!exists)
            try B.append(total_path);
        }
        // log("AAAAAAAAAAAA: {any}\n", .{B});

        // This handles the case of there being no spur paths, or no spur paths left.
        // This could happen if the spur paths have already been exhausted (added to A),
        // or there are no spur paths at all - such as when both the source and sink vertices
        // lie along a "dead end".
        if (B.items.len == 0) break;

        // Sort B by increasing order of path cost
        insertionSort(&B.items, graph);

        // Add the lowest cost path in B to A
        try A.append(B.items[0]);
        B.items = B.items[1..];
    }

    return A.clone();
}

// Insertion sort for sorting paths by cost
fn insertionSort(paths: *[]Path, graph: Graph) void {
    for (1..paths.len) |i| {
        const key = paths.*[i];
        var j: isize = @intCast(i);
        j -= 1;

        while (j >= 0 and key.get_cost(graph.adj) < paths.*[@intCast(j)].get_cost(graph.adj)) : (j -= 1) {
            paths.*[@intCast(j + 1)] = paths.*[@intCast(j)];
        }

        paths.*[@intCast(j + 1)] = key;
    }
}
