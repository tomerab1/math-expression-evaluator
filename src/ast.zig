const eql = @import("std").mem.eql;
const print = @import("std").debug.print;
const expect = @import("std").testing.expect;
const allocator = @import("std").heap.page_allocator;
const Token = @import("./tokens.zig").Token;

pub const ASTNode = struct {
    left: ?*const ASTNode = null,
    right: ?*const ASTNode = null,
    node_token: ?Token = null,
    node_val: ?f32 = null,

    pub fn init(left: ?*const @This(), right: ?*const @This(), token: ?Token, val: ?f32) ASTNode {
        return ASTNode{
            .left = left,
            .right = right,
            .node_token = token,
            .node_val = val,
        };
    }

    pub fn eval(self: ?*const @This()) error{ INVALID_OPERANDS, ZERO_DIVISION }!f32 {
        if (self) |node| {
            if (node.node_token) |token| {
                return switch (token) {
                    .@"+" => node.left.?.node_val.? + node.right.?.node_val.?,
                    .@"*" => node.left.?.node_val.? * node.right.?.node_val.?,
                    .@"-" => node.left.?.node_val.? - node.right.?.node_val.?,
                    .@"/" => if (node.right.?.node_val.? == 0) error.ZERO_DIVISION else node.left.?.node_val.? / node.right.?.node_val.?,
                    else => error.INVALID_OPERANDS,
                };
            }
        }
        return error.INVALID_OPERANDS;
    }

    var indent_level: u8 = 0;

    pub fn printASTNode(self: ?*const @This()) !void {
        if (self) |node| {
            print("{s}token: {?s}, value: {?d}\n", .{ (try createIndentation(' ', indent_level)), Token.getTokenKind(node.node_token orelse .invalid), node.node_val });
            indent_level += 4;
            try printASTNode(node.left);
            try printASTNode(node.right);
            indent_level -= 4;
        }
    }
};

fn createIndentation(char: u8, n: u8) ![]u8 {
    var buffer: [255:0]u8 = undefined;
    var i: u8 = 0;

    while (i < n) : (i += 1) {
        buffer[i] = char;
    }

    buffer[n + 1] = 0;
    var message_copy = try allocator.dupe(u8, buffer[0..n]);
    return message_copy;
}

test "create indentation" {
    try expect((try createIndentation(' ', 100)).len == 100);
}

test "eval bin-op" {
    var left = ASTNode.init(null, null, .NUMBER, 5);
    var right = ASTNode.init(null, null, .NUMBER, 10);

    const parentAdd = ASTNode.init(&left, &right, .@"+", null);
    const parentSub = ASTNode.init(&left, &right, .@"-", null);
    const parentDiv = ASTNode.init(&left, &right, .@"/", null);
    const parentMult = ASTNode.init(&left, &right, .@"*", null);

    try expect(try parentAdd.eval() == 15);
    try expect(try parentDiv.eval() == 0.5);
    try expect(try parentMult.eval() == 50);
    try expect(try parentSub.eval() == -5);
}

test "eval division by zero" {
    var left = ASTNode.init(null, null, .NUMBER, 5);
    var right = ASTNode.init(null, null, .NUMBER, 0);
    const parent = ASTNode.init(&left, &right, .@"/", null);

    _ = parent.eval() catch |err| {
        try expect(err == error.ZERO_DIVISION);
    };
}

test "binary op node" {
    var left = ASTNode.init(null, null, .NUMBER, 5);
    var right = ASTNode.init(null, null, .NUMBER, 10);
    const parent = ASTNode.init(&left, &right, .@"+", null);

    try expect(parent.left.?.left == null);
    try expect(parent.left.?.right == null);
    try expect(parent.left.?.node_token == .NUMBER);
    try expect(parent.left.?.node_val == 5);

    try expect(parent.right.?.left == null);
    try expect(parent.right.?.right == null);
    try expect(parent.right.?.node_token == .NUMBER);
    try expect(parent.right.?.node_val == 10);

    try expect(parent.left == &left);
    try expect(parent.right == &right);
    try expect(parent.node_token == .@"+");
    try expect(parent.node_val == null);
}
