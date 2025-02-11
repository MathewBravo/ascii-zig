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

pub fn normalizeVec3(vec: *Vec3) !void {
    const len = lengthVec3(*vec);

    if (len == 0) {
        return 0;
    }

    vec[0] /= len;
    vec[1] /= len;
    vec[2] /= len;
}

pub fn distVec3(left: Vec3, right: Vec3) f32 {
    const x: f32 = left[0] - right[0];
    const y: f32 = left[1] - right[1];
    const z: f32 = left[2] - right[2];

    return std.math.sqrt(x * x + y * y + z * z);
}

pub fn xrotateVec3(vec: *Vec3, angle: f32) !void {
    const x: f32 = vec[0];
    const y: f32 = vec[1] * std.math.cos(angle) + vec[2] * std.math.sin(angle);
    const z: f32 = -std.math.sin(angle) * vec[1] + vec[2] * std.math.cos(angle);

    vec[0] = x;
    vec[1] = y;
    vec[2] = z;
}

pub fn yrotateVec3(vec: *Vec3, angle: f32) !void {
    const x: f32 = std.math.cos(angle) * vec[0] - std.math.sin(angle) * vec[2];
    const y: f32 = vec[1];
    const z: f32 = std.math.sin(angle) * vec[0] + std.math.cos(angle) * vec[2];

    vec[0] = x;
    vec[1] = y;
    vec[2] = z;
}

pub fn zrotateVec3(vec: *Vec3, angle: f32) !void {
    const x: f32 = vec[0] * std.math.cos(angle) + vec[1] * std.math.sin(angle);
    const y: f32 = -std.math.sin(angle) * vec[0] + std.math.cos(angle) * vec[1];
    const z: f32 = vec[2];

    vec[0] = x;
    vec[1] = y;
    vec[2] = z;
}

pub fn planeIntersectionVec3(plane_point: Vec3, plane_normal: Vec3, line_start: Vec3, line_end: Vec3) Vec3 {
    var line_start_to_end: Vec3 = undefined;
    var line_to_intersectoin: Vec3 = undefined;

    normalizeVec3(&plane_normal);
    const plane_d = -dotVec3(plane_normal, plane_point);
    const ad = dotVec3(line_start, plane_normal);
    const bd = dotVec3(line_end, plane_normal);
    const t = (-plane_d - ad) / (bd - ad);

    line_start_to_end = subVec3(line_end, line_start);
    line_to_intersectoin = line_start_to_end;
    scaleVec3(&line_to_intersectoin, t);

    return addVec3(line_start, line_to_intersectoin);
}

pub fn triangleClipPlane(plane_point: Vec3, plane_normal: Vec3, in_tri: Triangle) struct {
    count: u8,
    tri1: ?Triangle,
    tri2: ?Triangle,
} {
    normalizeVec3(&plane_normal);

    // Compute signed distances from triangle vertices to the plane
    var dist: [3]f32 = undefined;
    dist[0] = dotVec3(plane_normal, in_tri.vert1) - dotVec3(plane_normal, plane_point);
    dist[1] = dotVec3(plane_normal, in_tri.vert2) - dotVec3(plane_normal, plane_point);
    dist[2] = dotVec3(plane_normal, in_tri.vert3) - dotVec3(plane_normal, plane_point);

    var inside_points: [3]Vec3 = undefined;
    var outside_points: [3]Vec3 = undefined;
    var nInside: usize = 0;
    var nOutside: usize = 0;

    // Classify points
    if (dist[0] >= 0) {
        inside_points[nInside] = in_tri.vert1;
        nInside += 1;
    } else {
        outside_points[nOutside] = in_tri.vert1;
        nOutside += 1;
    }

    if (dist[1] >= 0) {
        inside_points[nInside] = in_tri.vert2;
        nInside += 1;
    } else {
        outside_points[nOutside] = in_tri.vert2;
        nOutside += 1;
    }

    if (dist[2] >= 0) {
        inside_points[nInside] = in_tri.vert3;
        nInside += 1;
    } else {
        outside_points[nOutside] = in_tri.vert3;
        nOutside += 1;
    }

    // Case 1: All points are outside

    if (nInside == 0) {
        return .{ .count = 0, .tri1 = null, .tri2 = null };
    }

    // Case 2: All points are inside
    if (nInside == 3) {
        return .{ .count = 1, .tri1 = in_tri, .tri2 = null };
    }

    // Case 3: One inside, two outside (triangle shrinks)
    if (nInside == 1 and nOutside == 2) {
        return .{
            .count = 1,
            .tri1 = Triangle{
                .vert1 = inside_points[0],
                .vert2 = planeIntersectionVec3(plane_point, plane_normal, inside_points[0], outside_points[0]),
                .vert3 = planeIntersectionVec3(plane_point, plane_normal, inside_points[0], outside_points[1]),
            },
            .tri2 = null,
        };
    }

    // Case 4: Two inside, one outside (triangle splits into two)
    if (nInside == 2 and nOutside == 1) {
        const p1 = planeIntersectionVec3(plane_point, plane_normal, inside_points[0], outside_points[0]);
        const p2 = planeIntersectionVec3(plane_point, plane_normal, inside_points[1], outside_points[0]);

        return .{
            .count = 2,
            .tri1 = Triangle{
                .vert1 = inside_points[0],
                .vert2 = inside_points[1],
                .vert3 = p1,
            },

            .tri2 = Triangle{
                .vert1 = inside_points[1],

                .vert2 = p1,
                .vert3 = p2,
            },
        };
    }

    return .{ .count = 0, .tri1 = null, .tri2 = null };
}
