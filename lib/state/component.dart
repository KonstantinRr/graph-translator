import 'package:fraction/fraction.dart';

/*
abstract class TwoArgComponent extends Component {
  Input i1, i2;
  Output o;

  TwoArgComponent(this.i1, this.i2, this.o);

}

class ComponentSub extends TwoArgComponent {
  ComponentSub(Component i1, Component i2, Component o) 

  @override
  void validate() {
    if (i1 == null || i2)
  }
}

class ComponentAdd extends Component {}

class ComponentMul extends Component {}

class ComponentDiv extends Component {}

class ComponentMod extends Component {}

class ComponentAnd extends Component {}

class ComponentXor extends Component {}

class ComponentOr extends Component {}

class ComponentNeg extends Component {}
*/

class Input {
  dynamic buffer;
  Output connectedOutput;

  bool allowInt() {
    return false;
  }

  bool allowFraction() {
    return false;
  }

  bool allowDouble() {
    return false;
  }

  bool allowBool() {
    return false;
  }
}

class Output {
  dynamic buffer;
  Input connectedInput;
}
