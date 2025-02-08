const std = @import("std");

pub const Vec3 = @Vector(3, f32);

pub const Triangle = struct {
    vert1: Vec3,
    vert2: Vec3,
    vert3: Vec3,
};

pub fn addVec3(left: Vec3, right: Vec3) Vec3 {
    return left + right;
}

pub fn subVec3(left: Vec3, right: Vec3) Vec3 {
    return left - right;
}

pub fn crossVec3(left: Vec3, right: Vec3) Vec3 {
    return Vec3{
        (left[1] * right[2]) - (left[2] * right[1]),
        (left[2] * right[0]) - (left[0] * right[2]),
        (left[0] * right[1]) - (left[1] * right[0]),
    };
}

pub fn dotVec3(left: Vec3, right: Vec3) f32 {
    return left[0] * right[0] + left[1] * right[1] + left[2] * right[2];
}

pub fn lengthVec3(vec: Vec3) f32 {
    return std.math.sqrt(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
}

pub fn scaleVec3(vec: *Vec3, scale: f32) void {
    vec[0] *= scale;
    vec[1] *= scale;
    vec[2] *= scale;
}

pub fn angleVec3(left: Vec3, right: Vec3) f32 {
    const leftLen = lengthVec3(left);
    const rightLen = lengthVec3(right);

    if (leftLen == 0 or rightLen == 0) {
        return 0;
    }

    const dot = dotVec3(left, right);
    return std.math.acos(dot / (leftLen * rightLen));
}

pub fn normalizeVec3(vec: Vec3) !void {
    const len = lengthVec3(*vec);

    if (len == 0) {
        return 0;
    }

    vec[0] /= len;
    vec[1] /= len;
    vec[2] /= len;
}
