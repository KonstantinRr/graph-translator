import 'dart:collection';
import 'dart:typed_data';
import 'dart:math' as math;

abstract class SizeObject with IterableMixin<double>{
  Float32List _data;

  /// Creates a new SizeObject of the given [size].
  /// All entries are initialized to zero.
  SizeObject(int size) :
    _data = Float32List(size);
  /// Creates a new SizeObject of the given size filling it with
  /// random values. The optional RNG is used, if specified.
  SizeObject.random(int size, [math.Random rand]) :
    _data = Float32List(size) {
    rand ??= math.Random();
    for (var i = 0; i < dimension; i++)
      _data[i] = rand.nextDouble();
  }
  /// Creates a copy of [object]
  SizeObject.copy(SizeObject object) :
    _data = Float32List(object.dimension)
  {
    for (var i = 0; i < object.dimension; i++)
      _data[i] = object._data[i];
  }
  /// Creates a SizeObject from a [List]
  SizeObject.fromList(List<double> list) :
    _data = Float32List.fromList(list);

  // abstract functions //
  int get columns;
  int get rows;
  int get width;
  int get height;
  int get dimension;
  // abstract functions //
  int get length => _data.length;
  int get lengthInBytes => _data.lengthInBytes;
  Float32List get buffer => _data;

  @override
  Iterator<double> get iterator => _data.iterator;

  double operator[](int idx) => _data[idx];
  void operator[]=(int idx, double value) => _data[idx] = value;
}

class Vector extends SizeObject{

  Vector(int length) : super(length);
  Vector.copy(Vector vector) : super.copy(vector);
  Vector.fromList(List<double> values) : super.fromList(values);
  Vector.random(int length) : super.random(length);

  int get columns => 1;
  int get rows => _data.length;
  int get width => 1;
  int get height => _data.length;
  int get dimension => _data.length;

  static void _checkLength(Vector n1, Vector n2) {
    if (n1.length != n2.length)
      throw ArgumentError('Vectors must match in dimension '
        '${n1.length}:${n2.length}');
  }

  Vector applyOperator(Object n, double Function(double, double) func) {
    var vec = Vector.copy(this);
    if (n is num) {
      for (var i = 0; i < _data.length; i++)
        vec._data[i] = func(vec._data[i], n);
    } else if (n is Vector) {
      _checkLength(this, n);
      for (var i = 0; i < _data.length; i++)
        vec._data[i] = func(vec._data[i], n._data[i]);
    } else {
      throw ArgumentError('Invalid Type!');
    }
    return vec;
  }

  Vector operator +(Object n) => applyOperator(n, (v1, v2) => v1 + v2);
  Vector operator -(Object n) => applyOperator(n, (v1, v2) => v1 - v2);
  Vector operator *(Object n) => applyOperator(n, (v1, v2) => v1 * v2);
  Vector operator /(Object n) => applyOperator(n, (v1, v2) => v1 / v2);

  double dot(Vector vec) {
    _checkLength(this, vec);
    double sum = 0.0;
    for (var i = 0; i < _data.length; i++)
      sum += _data[i] * vec._data[i];
    return sum;
  }

  @override
  String toString() {
    var buffer = StringBuffer();
    buffer.write('Vector [${_data.length}]');
    for (var i = 0; i < _data.length; i++) {
      buffer.write(_data[i].toStringAsFixed(3));
      buffer.write(' ');
    }
    return buffer.toString();
  }
}

class Matrix extends SizeObject with IterableMixin<double> {
  int _width, _height;

  Matrix(int width, int height) :
    _width = width, _height = height,
    super(width * height);

  Matrix.copy(Matrix mat) :
    _width = mat.width, _height = mat.height,
    super.copy(mat);

  Matrix.random(int width, int height, [math.Random rand]) :
    _width = width, _height = height,
    super.random(width * height);

  factory Matrix.fromList(List<List<double>> rows) {
    // checks if the input list matches all conditions
    if (rows.isEmpty)
      throw ArgumentError('List must contain at least one column.');
    int sizeStart = rows.first.length;
    for (var row in rows) {
      if (row.length == 0)
        throw ArgumentError('Row must contain at least one value.');
      if (row.length != sizeStart)
        throw ArgumentError('Row length must match length of all other rows.');
    }
    // initalizes the members

    var height = rows.length;
    var width = rows[0].length;
    var matrix = Matrix(width, height);

    int idx = 0;
    for (var row in rows) {
      for (var value in row)
        matrix[idx++] = value;
    }
    return matrix;
  }

  // implemented functions //

  int get columns => _width;
  int get rows => _height;
  int get width => _width;
  int get height => _height;
  int get dimension => _width * _height;

  // implemented functions //

  int getPosition(int widthIdx, int heightIdx) =>
    _width * heightIdx + widthIdx;
  double getValue(int widthIdx, int heightIdx) =>
    _data[_width * heightIdx + widthIdx];

  Matrix multiplyMatrix(Matrix matrix) {
    if (_width != matrix._height)
      throw ArgumentError('Number of columns $_width must '
        'be equal to number rows ${matrix._height}');
    // new width is the width of the multiplies matrix
    // new height is the height of the original matrix
    Matrix newMatrix = Matrix(matrix._width, _height);
    int idx = 0, heightValue = 0;
    for (int heightIdx = 0; heightIdx < _height; heightIdx++) {
      for (int widthIdx = 0; widthIdx < matrix._width; widthIdx++) {
        int widthValue = widthIdx;
        for (int i = 0; i < _width; i++) {
          newMatrix._data[idx] +=
            _data[heightValue + i] *
            _data[widthValue];
          widthValue += _width;
        }
        idx++;
      }
      heightValue += _width;
    }
    return newMatrix;
  }

  

  void toStochasticMatrix() {
    //for (var hIdx = 0; hIdx < dimension; hIdx += _width) {
    //  double factor = 0.0;
    //  for (var wIdx = hIdx; wIdx < hIdx + _width; wIdx++)
    //    factor += _data[wIdx];
    //  for (var wIdx = hIdx; wIdx < hIdx + _width; wIdx++)
    //    sum += _data[wIdx];
    //}
    return null;
  }

  Matrix asStochasticMatrix() {
    return Matrix.copy(this)..toStochasticMatrix();
  }

  Vector multiplyVector(Vector vec) {
    return null;
  }

  Matrix square() => this * this;

  Matrix limit([int iterations = 5]) {
    Matrix lim = this;
    for (var i = 0; i < iterations; i++)
      lim = lim.square();
    return lim;
  }



  SizeObject operator *(SizeObject other) {
    if (other is Vector)
      return multiplyVector(other);
    else if (other is Matrix)
      return multiplyMatrix(other);
    throw ArgumentError('Object must be of type Vector or Matrix.');
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Matrix[$width][$height]\n');
    var idx = 0;
    for (var heightIdx = 0; heightIdx < height; heightIdx++) {
      for (var widthIdx = 0; widthIdx < width; widthIdx++) {
        buffer.write(this[idx++].toStringAsFixed(3));
        buffer.write(' '); // space
      }
      buffer.write('\n');
    }
    return buffer.toString();
  }
}

void testMatrix() {
  var mat1 = Matrix.fromList([[1, 2], [3, 4]]);
  var d1 = DateTime.now();
  mat1 = mat1.multiplyMatrix(mat1);
  var d2 = DateTime.now();
  print(d2.difference(d1));
  print(mat1);
}