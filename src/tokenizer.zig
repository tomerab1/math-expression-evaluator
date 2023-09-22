const Token = @import("tokens.zig").Token;
const ArrayList = @import("std").ArrayList;
const Allocator = @import("std").mem.Allocator;
const testing_allocator = @import("std").testing.allocator;
const expect = @import("std").testing.expect;
const eql = @import("std").mem.eql;
const print = @import("std").debug.print;

const TokenizerErrors = error{
    INVALID_TOKEN,
    OutOfMemory,
};

fn isDigit(char: u8) bool {
    return '0' <= char and char <= '9';
}

pub const Tokenizer = struct {
    items: ArrayList(Token) = undefined,

    pub fn init(self: *@This(), list_allocator: Allocator) void {
        self.items = ArrayList(Token).init(list_allocator);
    }

    pub fn deinit(self: *@This()) void {
        defer self.items.deinit();
    }

    pub fn tokenize(self: *@This(), input: []const u8) TokenizerErrors!ArrayList(Token) {
        var i: u32 = 0;
        while (i < input.len) {
            const curr_char = input[i];
            switch (curr_char) {
                '(' => {
                    try self.items.append(.@"(");
                    i += 1;
                },
                ')' => {
                    try self.items.append(.@")");
                    i += 1;
                },
                '*' => {
                    try self.items.append(.@"*");
                    i += 1;
                },
                '+' => {
                    try self.items.append(.@"+");
                    i += 1;
                },
                '-' => {
                    try self.items.append(.@"-");
                    i += 1;
                },
                '/' => {
                    try self.items.append(.@"/");
                    i += 1;
                },
                '\t' => {
                    i += 1;
                },
                ' ' => {
                    i += 1;
                },
                '0'...'9' => {
                    try self.items.append(.NUMBER);
                    while (i < input.len and isDigit(input[i])) : (i += 1) {}
                },
                else => {
                    return error.INVALID_TOKEN;
                },
            }
        }

        return self.items;
    }
};

test "init Tokenizer" {
    var tokenizer = Tokenizer{};
    tokenizer.init(testing_allocator);
    defer tokenizer.deinit();
}

test "tokenize ok" {
    var tokenizer = Tokenizer{};
    tokenizer.init(testing_allocator);
    defer tokenizer.deinit();

    const tokens = try tokenizer.tokenize("(100+2)*30");
    const items = tokens.items;

    try expect(eql(u8, Token.getTokenKind(items[0]), "L_PAREN"));
    try expect(eql(u8, Token.getTokenKind(items[1]), "NUMBER"));
    try expect(eql(u8, Token.getTokenKind(items[2]), "PLUS"));
    try expect(eql(u8, Token.getTokenKind(items[3]), "NUMBER"));
    try expect(eql(u8, Token.getTokenKind(items[4]), "R_PAREN"));
    try expect(eql(u8, Token.getTokenKind(items[5]), "MULT"));
    try expect(eql(u8, Token.getTokenKind(items[6]), "NUMBER"));
}

test "tokenize invalid" {
    var tokenizer = Tokenizer{};
    tokenizer.init(testing_allocator);
    defer tokenizer.deinit();

    const tokens = tokenizer.tokenize("(100+a)*30");
    try expect(tokens == error.INVALID_TOKEN);
}
