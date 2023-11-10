const std = @import("std");
const print = std.debug.print;
const Graph = @import("Graph.zig").Graph;

pub const Path = struct {
    nodes: [Graph.NODE_AMOUNT]u32,
    cost: u32,

    pub fn init() Path {
        return Path{
            .nodes = [_]u32{Graph.FILLER} ** Graph.NODE_AMOUNT,
            .cost = 0,
        };
    }

    pub fn append(self: *Path, node: u32) !*Path {
        for (0..Graph.NODE_AMOUNT) |i| {
            if (i == Graph.NODE_AMOUNT - 1) return error.FULL_PATH;
            if (self.nodes[i] != Graph.FILLER) continue;
            self.nodes[i] = node;
        }
        return self;
    }

    pub fn contains(self: Path, node: u32) bool {
        for (self.nodes) |n| {
            if (n == node) return true;
        }
        return false;
    }
};

/// Breadth-First Search
pub fn bfs(graph: Graph, source: u32, target: u32) !Path {
    _ = graph;
    const helper = struct {
        fn helper(node: u32, node_target: u32, history: *Path) ?*Path {
            // target is found
            if (node == node_target) {
                // add the target into history
                return history.append(node) catch null;
            }

            // node was visited
            if (history.contains(node)) return null;

            // resume

            return history;
        }
    };

    var history = Path.init();
    var result = helper.helper(source, target, &history);

    return result.?.*;
}

// bfs: entry must have: history, current node index
