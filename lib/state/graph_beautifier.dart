import 'package:vector_math/vector_math.dart';

class FunctionSettings {
  final double k;
  final double repellFactor, repellPower;
  final double pullFactor, pullPower;

  const FunctionSettings(
      {this.k = 10.0,
      this.repellFactor = 1.0,
      this.repellPower = 1.0,
      this.pullFactor = 1.0,
      this.pullPower = 1.0});
}

/*
void simulatePositions(int iterations,
    {FunctionSettings nodeSettings, FunctionSettings edgeSettings}) {
  // The default node settings, used if [nodeSettings] is null
  nodeSettings ??= const FunctionSettings(
    k: 300.0,
    repellFactor: 0.01,
    repellPower: 1.0,
    pullFactor: 0.0,
    pullPower: 0.0,
  );
  // The default edge settings, used if [edgeSettings] is null
  edgeSettings ??= const FunctionSettings(
      k: 100.0,
      repellFactor: 0.0,
      repellPower: 1.0,
      pullFactor: 0.005,
      pullPower: 1.0);

  // Defines the force function that returns the force
  // that is applied to the current node.
  var forceFn = (Node nd1, Node nd2, FunctionSettings s) {
    Vector2 distanceVec = nd2.vec - nd1.vec;
    var d = distanceVec.length;
    var factor = 0.0;
    if (d < s.k)
      factor = (s.repellFactor * math.pow(d - s.k, s.repellPower));
    else if (d > s.k) factor = (s.pullFactor * math.pow(d - s.k, s.pullPower));
    return distanceVec.normalized() * factor;
  };

  for (var t = 0; t < iterations; t++) {
    List<Vector2> newPositions = List.filled(nodes.length, Vector2.zero());
    for (var i = 0; i < nodes.length; i++) {
      Vector2 force = Vector2.zero();
      for (var edge in nodes[i].outEdges)
        force += forceFn(nodes[i], edge.destination, edgeSettings);
      for (var otherNode in nodes) {
        if (otherNode != nodes[i])
          force += forceFn(nodes[i], otherNode, nodeSettings);
      }
      newPositions[i] = nodes[i].vec + force;
    }

    // Applies the new positions
    for (var i = 0; i < nodes.length; i++) {
      nodes[i].x = newPositions[i].x;
      nodes[i].y = newPositions[i].y;
    }
  }
}
*/
