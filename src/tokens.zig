const std = @import("std");
const expect = std.testing.expect;
const eql = std.mem.eql;

pub const Token = enum {
    NUMBER,
    @"+",
    @"-",
    @"*",
    @"/",
    @"(",
    @")",
    @" ",
    @"\t",
    invalid,

    pub fn getTokenKind(token: @This()) []const u8 {
        return switch (token) {
            .@"(" => "L_PAREN",
            .@")" => "R_PAREN",
            .@"*" => "MULT",
            .@"+" => "PLUS",
            .@"-" => "MINUS",
            .@"/" => "DIV",
            .@" " => "SPACE",
            .@"\t" => "TAB",
            .NUMBER => "NUMBER",
            else => "INVALID",
        };
    }
};

test "test Token" {
    const token = Token.@"*";
    try expect(eql(u8, token.getTokenKind(), "MULT"));
}
