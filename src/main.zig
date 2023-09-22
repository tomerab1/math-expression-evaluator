const std = @import("std");
const print = std.debug.print;
const allocator = @import("std").heap.page_allocator;
const Tokenizer = @import("./tokenizer.zig").Tokenizer;
const Token = @import("./tokens.zig").Token;
const ASTNode = @import("./ast.zig").ASTNode;

pub fn main() !void {
    var tokenizer = Tokenizer{};
    tokenizer.init(allocator);
    defer tokenizer.deinit();

    const tokens = try tokenizer.tokenize("(100+2)*30");
    for (tokens.items) |token| {
        std.debug.print("{s}\n", .{Token.getTokenKind(token)});
    }

    const left = ASTNode.init(null, null, .NUMBER, 5);
    const right = ASTNode.init(null, null, .NUMBER, 10);
    const parent = ASTNode.init(&left, &right, .@"+", null);

    try parent.printASTNode();
}
