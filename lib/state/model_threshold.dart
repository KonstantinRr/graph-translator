/// This project is build during the Bachelor Project at the
/// UNIVERSITY OF GRONINGEN.
/// The project was build by:
/// Konstantin Rolf (S3750558) - k.rolf@student.rug.nl

import 'package:graph_translator/state/graph_undirected.dart';
import 'package:graph_translator/state/model_general.dart';

class GlobalThresholdNode extends UndirectedNode {
  GlobalThresholdNode({double ?x, double ?y}) : super(x: x, y: y);
}

class GlobalThresholdGraph extends GraphUndirected {
  final double threshold;

  GlobalThresholdGraph(this.threshold);
  
  @override
  UndirectedNode createNode() => UndirectedNode();
  UndirectedEdge createEdge(UndirectedNode n1, UndirectedNode n2) => UndirectedUnweightedEdge(n1, n2);


}

class ModelThreshold extends ModelGeneral {

  @override
  void reset() {

  }

  @override
  void computeStep() {

  }
}