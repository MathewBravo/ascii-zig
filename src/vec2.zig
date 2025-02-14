pub const Vec2 = @Vector(2, f32);

pub fn addVec2(left: Vec2, right: Vec2) !Vec2 {
    return left + right;
}

pub fn subVec2(left: Vec2, right: Vec2) !Vec2 {
    return left - right;
}

pub fn dotVec2(left: Vec2, right: Vec2) f32 {
    return @reduce(.Add, left * right);
}
