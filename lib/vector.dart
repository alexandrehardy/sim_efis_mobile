import 'dart:math';

class Vector {
  double x;
  double y;
  double z;

  Vector({
    required this.x,
    required this.y,
    required this.z,
  });

  static Vector from({
    required double latitude,
    required double longitude,
  }) {
    double y = sin(latitude * pi / 180.0);
    double radius = cos(latitude * pi / 180.0);
    double x = radius * cos(longitude * pi / 180.0);
    double z = radius * sin(longitude * pi / 180.0);
    return Vector(x: x, y: y, z: z);
  }

  double dot(Vector b) {
    return x * b.x + y * b.y + z * b.z;
  }

  double length() {
    return sqrt(dot(this));
  }

  Vector normalize() {
    double l = length();
    return Vector(x: x / l, y: y / l, z: z / l);
  }

  Vector operator +(Vector b) {
    return Vector(x: x + b.x, y: y + b.y, z: z + b.z);
  }

  Vector operator -(Vector b) {
    return Vector(x: x - b.x, y: y - b.y, z: z - b.z);
  }

  Vector operator *(double b) {
    return Vector(x: x * b, y: y * b, z: z * b);
  }

  double angle(Vector b) {
    double cosine = normalize().dot(b.normalize());
    return acos(cosine);
  }

  double angleAlreadyNormal(Vector b) {
    double cosine = dot(b);
    return acos(cosine);
  }

  Vector tangent() {
    // Compute a tangent on the sphere going west->east
    return Vector(x: z, y: 0.0, z: -x).normalize();
  }

  double heading(Vector dest) {
    Vector middle = (this + dest) * 0.5;
    middle = middle.normalize();
    Vector dst = dest * (1.0 / dest.dot(middle));
    Vector tangent = middle.tangent();
    Vector head = dst - middle;
    if (head.dot(head) < 1e-15) {
      return 0.0;
    }
    Vector zeroHeading = Vector(x: 0, y: 1, z: 0) - middle;
    zeroHeading = zeroHeading - middle * zeroHeading.dot(middle);
    zeroHeading = zeroHeading.normalize();
    double angle = acos(head.normalize().dot(zeroHeading));
    if (head.dot(tangent) > 0) {
      return (2 * pi - angle) * 180.0 / pi;
    } else {
      return angle * 180.0 / pi;
    }
  }

  @override
  String toString() {
    return '<$x, $y, $z>';
  }
}
