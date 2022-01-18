import 'dart:convert';

import 'dart:io';

enum Action { Add, Explode, Split }

// I couldn't figure out a great data structure, and string manipulation seemed
// like it would be Not Fun, so I want with this weird hybrid tree/integer
// structure. A SFN of [2, 3] would be modelled as a root node with
// parent = null, left node of SFN where left & right = null and value = 2,
// and right node of SFN where left & right = null and value = 2.
// [[2, 3], 4] would be the root node where:
//    parent = null
//    left is a SFN
//      where parent = root,
//      left = SFN (which has left = right = null, value = 2, parent = this),
//      right = SFN (left = right = null, value = 3, parent = this)
//    right is a SFN
//      where parent = root, left = right = null, value = 4.
// That is: a SFN either has two children (ie: it is a node), xor it has a value.
class SnailfishNumber {
  SnailfishNumber? left;
  SnailfishNumber? right;
  SnailfishNumber? parent;
  int? value;

  // Create a "value" sfn.
  SnailfishNumber(parent, value)
      : parent = parent,
        value = value;

  // Create a "node" sfn.
  SnailfishNumber.recurse(parent, left, right)
      : parent = parent,
        left = left,
        right = right {
    left.parent = this;
    right.parent = this;
  }

  // From a list like [[2, 3], 4], create a SFN.
  SnailfishNumber.fromList(SnailfishNumber? parent, List n) {
    this.parent = parent;
    if (n[0].runtimeType != int) {
      left = SnailfishNumber.fromList(this, n[0]);
    } else {
      left = SnailfishNumber(this, n[0]);
    }
    if (n[1].runtimeType != int) {
      right = SnailfishNumber.fromList(this, n[1]);
    } else {
      right = SnailfishNumber(this, n[1]);
    }
  }

  // Helper function to determine if anything needs to explode. From a node
  // you climb the tree until you get to the root value. Each step adds one to depth.
  int getDepth() {
    int d = 0;
    SnailfishNumber? p = parent;
    while (p != null) {
      d++;
      p = p.parent;
    }
    return d;
  }

  // Helper function to print.
  String toString() {
    if (value != null) return value.toString();
    String s = '[';
    s += left.toString();
    s += ', ';
    s += right.toString();
    s += ']';
    return s;
  }

  // Traverse the tree from the left most values to the right most values.
  // If we encounter a value of 10 or more, we split it and make the value SFN
  // into a node SFN with the left and right children as half the value.
  bool split() {
    if (value != null) {
      if (value! >= 10) {
        left = SnailfishNumber(this, (value! / 2).floor());
        right = SnailfishNumber(this, (value! / 2).ceil());
        value = null;
        return true;
      }
      return false;
    } else {
      // Lazy eval here--if we split anywhere on the left branch of this node,
      // the || will always be true. Consequently, the function will return
      // true without evaluating right.split, which is what we want.
      return left!.split() || right!.split();
    }
  }

  bool explode() {
    // Only explode if we are at a value node where depth > 4.
    if (this.getDepth() <= 4) {
      if (value != null) return false;
      return left!.explode() || right!.explode();
    }

    // We found a node where depth > 4.
    // Because of the way the problem is specified, we will only ever see depth
    // > 4 on a value node. We actually want to explode the parent (eg: [2, 3]).
    // So, let's create some variables to help track where in the tree we are
    // and to help us traverse the tree.
    SnailfishNumber target = this.parent!;
    SnailfishNumber? target_parent = this.parent!.parent!;
    SnailfishNumber temp = target;

    // Find the right-most .value to the left of target
    while (target_parent != null && target_parent.left == temp) {
      temp = target_parent;
      target_parent = target_parent.parent;
    }
    if (target_parent != null) {
      temp = target_parent.left!;
      while (temp.right != null) {
        temp = temp.right!;
      }
      // Ok, we have found the right-most .value to the left of the exploding pair,
      // so add the left value in the exploding pair to the found value.
      temp.value = temp.value! + target.left!.value!;
    }

    //Now, find the left-most .value to the right of target
    target_parent = target.parent!;
    temp = target;
    while (target_parent != null && target_parent.right == temp) {
      temp = target_parent;
      target_parent = target_parent.parent;
    }
    if (target_parent != null) {
      temp = target_parent.right!;
      while (temp.left != null) {
        temp = temp.left!;
      }
      // Found the left-most right-value, so add again.
      temp.value = temp.value! + target.right!.value!;
    }

    // Finally, because the target has exploded, it becomes a value node with
    // value = 0.
    target.left = null;
    target.right = null;
    target.value = 0;
    return true;
  }

  // Adding's easy. It's basically creating a new root node where left is
  // the "current" SFN and the right is the added SFN.
  SnailfishNumber add(SnailfishNumber n) {
    SnailfishNumber new_node = SnailfishNumber.recurse(this.parent, this, n);
    return new_node;
  }

  // Helper function to determine whether we should explode, split, or add next.
  // Traverse the tree downward from left to right. If any node should explode,
  // that's the next step. If no node should explode, but a value should split,
  // then that's the next step. Otherwise, we should add on the next number.
  Action whatNext() {
    if (this.getDepth() > 4) return Action.Explode;
    if (this.value != null) {
      if (this.value! >= 10) {
        return Action.Split;
      }
      return Action.Add;
    } else {
      Action leftAction = left!.whatNext();
      Action rightAction = right!.whatNext();
      if (leftAction == Action.Explode || rightAction == Action.Explode) return Action.Explode;
      if (leftAction == Action.Split || rightAction == Action.Split) return Action.Split;
      return Action.Add;
    }
  }

  // Returns the magnitude of the SFN (left * 3 + right * 2).
  int magnitude() {
    if (this.value != null) return this.value!;
    return this.left!.magnitude() * 3 + this.right!.magnitude() * 2;
  }

  // Pretty straightforward: reduce while there are numbers to explode/split.
  void reduce() {
    while (this.whatNext() != Action.Add) {
      if (this.whatNext() == Action.Split) {
        this.split();
      } else {
        this.explode();
      }
    }
  }
}

void main() {
  List<String> input = File('day18.txt').readAsLinesSync();

  //I couldn't figure out a great datastructure, so ultimately I went with this
  //weird kind of hybrid tree/integer, SnailfishNumber. Check out the comments
  //in the class to figure out what it's doing.
  SnailfishNumber n = SnailfishNumber.fromList(null, jsonDecode(input[0]));

  //Part 1
  for (int i = 1; i < input.length; i++) {
    n = n.add(SnailfishNumber.fromList(null, jsonDecode(input[i])));
    n.reduce();
  }
  print("Part 1: ${n.magnitude()}");

  // Part 2. If .add didn't mutate the calling string, this could be much cleaner.
  int maxMag = 0;
  for (int i = 0; i < input.length - 1; i++) {
    for (int j = i + 1; j < input.length; j++) {
      SnailfishNumber s1 = SnailfishNumber.fromList(null, jsonDecode(input[i]));
      SnailfishNumber s2 = SnailfishNumber.fromList(null, jsonDecode(input[j]));
      SnailfishNumber result = s1.add(s2)..reduce();
      int mag = result.magnitude();
      if (mag > maxMag) maxMag = mag;

      //.add mutates s1, so instead of fixing it we'll quick and dirty re-read
      //everything.
      s1 = SnailfishNumber.fromList(null, jsonDecode(input[i]));
      s2 = SnailfishNumber.fromList(null, jsonDecode(input[j]));
      result = s2.add(s1)..reduce();
      mag = result.magnitude();
      if (mag > maxMag) maxMag = mag;
    }
  }
  print("Part 2: $maxMag");
}
