// Include guard
#ifndef VB_GEOMETRY_H
#define VB_GEOMETRY_H

#include <vector>
#include <cstddef>
#include <assert.h>
#include <cmath>

namespace tess {

struct Edge;

struct Point {

  double x, y;

  /// Default constructor does nothing (for performance).
  Point()
  {
    x = 0.0;
    y = 0.0;
  }

  /// The edges this point constitutes an upper ending point
  std::vector<Edge*> edge_list;

  /// Construct using coordinates.
  Point(double x, double y) : x(x), y(y) {}

  /// Set this point to all zeros.
  void set_zero()
  {
    x = 0.0;
    y = 0.0;
  }

  /// Set this point to some specified coordinates.
  void set(double x_, double y_)
  {
    x = x_;
    y = y_;
  }

  /// Negate this point.
  Point operator -() const
  {
    Point v;
    v.set(-x, -y);
    return v;
  }

  /// Add a point to this point.
  void operator +=(const Point& v)
  {
    x += v.x;
    y += v.y;
  }

  /// Subtract a point from this point.
  void operator -=(const Point& v)
  {
    x -= v.x;
    y -= v.y;
  }

  /// Multiply this point by a scalar.
  void operator *=(double a)
  {
    x *= a;
    y *= a;
  }

  /// Get the length of this point (the norm).
  double Length() const
  {
    return sqrt(x * x + y * y);
  }

  /// Convert this point into a unit point. Returns the Length.
  double Normalize()
  {
    double len = Length();
    x /= len;
    y /= len;
    return len;
  }

};

// Represents a simple polygon's edge
struct Edge {

  Point* p, *q;

  /// Constructor
  Edge(Point& p1, Point& p2) : p(&p1), q(&p2)
  {
    if (p1.y > p2.y) {
      q = &p1;
      p = &p2;
    } else if (p1.y == p2.y) {
      if (p1.x > p2.x) {
        q = &p1;
        p = &p2;
      } else if (p1.x == p2.x) {
        // Repeat points
        assert(false);
      }
    }

    q->edge_list.push_back(this);
  }
};


class Triangle {
public:

/// Constructor
Triangle(Point& a, Point& b, Point& c);

/// Flags to determine if an edge is a Constrained edge
bool constrained_edge[3];
/// Flags to determine if an edge is a Delauney edge
bool delaunay_edge[3];

Point* GetPoint(const int& index);
Point* PointCW(Point& point);
Point* PointCCW(Point& point);
Point* OppositePoint(Triangle& t, Point& p);

Triangle* GetNeighbor(const int& index);
void MarkNeighbor(Point* p1, Point* p2, Triangle* t);
void MarkNeighbor(Triangle& t);

void MarkConstrainedEdge(const int index);
void MarkConstrainedEdge(Edge& edge);
void MarkConstrainedEdge(Point* p, Point* q);

int Index(const Point* p);
int EdgeIndex(const Point* p1, const Point* p2);

Triangle* NeighborCW(Point& point);
Triangle* NeighborCCW(Point& point);
bool GetConstrainedEdgeCCW(Point& p);
bool GetConstrainedEdgeCW(Point& p);
void SetConstrainedEdgeCCW(Point& p, bool ce);
void SetConstrainedEdgeCW(Point& p, bool ce);
bool GetDelunayEdgeCCW(Point& p);
bool GetDelunayEdgeCW(Point& p);
void SetDelunayEdgeCCW(Point& p, bool e);
void SetDelunayEdgeCW(Point& p, bool e);

bool Contains(Point* p);
bool Contains(const Edge& e);
bool Contains(Point* p, Point* q);
void Legalize(Point& point);
void Legalize(Point& opoint, Point& npoint);

void Clear();
void ClearNeighbor(Triangle *triangle );
void ClearNeighbors();
void ClearDelunayEdges();

inline bool IsInterior();
inline void IsInterior(bool b);

Triangle& NeighborAcross(Point& opoint);

void DebugPrint();

private:

/// Triangle points
Point* points_[3];
/// Neighbor list
Triangle* neighbors_[3];
bool interior_;
};

inline bool cmp(const Point* a, const Point* b)
{
  if (a->y < b->y) {
    return true;
  } else if (a->y == b->y) {
    // Make sure q is point with greater x value
    if (a->x < b->x) {
      return true;
    }
  }
  return false;
}

/// Add two points_ component-wise.
inline Point operator +(const Point& a, const Point& b)
{
  return Point(a.x + b.x, a.y + b.y);
}

/// Subtract two points_ component-wise.
inline Point operator -(const Point& a, const Point& b)
{
  return Point(a.x - b.x, a.y - b.y);
}

/// Multiply point by scalar
inline Point operator *(double s, const Point& a)
{
  return Point(s * a.x, s * a.y);
}

inline bool operator ==(const Point& a, const Point& b)
{
  return a.x == b.x && a.y == b.y;
}

inline bool operator !=(const Point& a, const Point& b)
{
  return a.x != b.x && a.y != b.y;
}

/// Peform the dot product on two vectors.
inline double Dot(const Point& a, const Point& b)
{
  return a.x * b.x + a.y * b.y;
}

/// Perform the cross product on two vectors. In 2D this produces a scalar.
inline double Cross(const Point& a, const Point& b)
{
  return a.x * b.y - a.y * b.x;
}

/// Perform the cross product on a point and a scalar. In 2D this produces
/// a point.
inline Point Cross(const Point& a, double s)
{
  return Point(s * a.y, -s * a.x);
}

/// Perform the cross product on a scalar and a point. In 2D this produces
/// a point.
inline Point Cross(const double s, const Point& a)
{
  return Point(-s * a.y, s * a.x);
}

inline Point* Triangle::GetPoint(const int& index)
{
  return points_[index];
}

inline Triangle* Triangle::GetNeighbor(const int& index)
{
  return neighbors_[index];
}

inline bool Triangle::Contains(Point* p)
{
  return p == points_[0] || p == points_[1] || p == points_[2];
}

inline bool Triangle::Contains(const Edge& e)
{
  return Contains(e.p) && Contains(e.q);
}

inline bool Triangle::Contains(Point* p, Point* q)
{
  return Contains(p) && Contains(q);
}

inline bool Triangle::IsInterior()
{
  return interior_;
}

inline void Triangle::IsInterior(bool b)
{
  interior_ = b;
}

}

#endif


