import 'dart:convert';
import 'dart:io';
import 'dart:mirrors';

class Submarine {
  int depth;
  int position;

  Submarine()
      : depth = 0,
        position = 0;

  void forward(int amount) {
    position += amount;
  }

  void up(int amount) {
    depth -= amount;
  }

  void down(int amount) {
    depth += amount;
  }

  int getFinalPosition() {
    return depth * position;
  }
}

class SubmarinePart2 extends Submarine {
  int aim;
  SubmarinePart2() : aim = 0;

  void forward(int amount) {
    super.forward(amount);
    depth += aim * amount;
  }

  void up(int amount) {
    aim -= amount;
  }

  void down(int amount) {
    aim += amount;
  }
}

Submarine? sub;
SubmarinePart2? sub2;

void move_sub(String line) {
  //Ok, so as I said we're using reflection. Each line is formatted as <command> <argument>.
  //Great, well each Submarine class has <command> as a method. We could very well do a
  //switch/case or ifelse chain and that would be perfectly cromulent. But so verbose. We
  //already know the command, so just call it directly! That's what reflection is for.

  //So the InstanceMirrors allow us to invoke the object's method's directly with .invoke.
  //Because we have two different objects that we want to reflect on, we need two mirrors.
  InstanceMirror m = reflect(sub);
  InstanceMirror m2 = reflect(sub2);

  //Great, let's get the command and argument.
  List<String> command = line.split(' ');

  //Invoke takes a Symbol (so we throw command[0] into a constructor for Symbol) and
  //a list of arguments taken by the method we are calling, so we wrap the parameter
  //command[1] in brackets to make it a list. Oh, and each function takes an int
  //so we need to make the operand an int, first.

  //Through the magic of reflection, m.invoke(forward, [5]) becomes sub.forward(5).
  //The classes above should be fairly straightforward, so let's just jump back
  //down to the .onDone in main().
  m.invoke(Symbol(command[0]), [int.parse(command[1])]);
  m2.invoke(Symbol(command[0]), [int.parse(command[1])]);
}

void main() async {
  //Do you like over engineered solutions? Then boy do I have the program for you.

  //So let's first get the data.
  File input_file = File('day2.txt');

  //Today, I'm going to actually try using streams. Dart io lets you asynchonously
  //read from files via Streams. Let's see in a moment what that does.
  Stream inputs = input_file.openRead();

  //I'm also going to do a new-concept double-whammy... let's talk about reflection!
  //To do so, I created two classes--one for part 1 and one for part 2. They need
  //instantiation, so here it is.
  sub = Submarine();
  sub2 = SubmarinePart2();

  //Great, so let's start reading the data in. First we need to tell Dart the charset (Utf8)
  //and then we need to tell Dart that we want to listen for any case that we hit a new line.
  //That new line is passed into the function move_sub. (This is how I have coneptualized it,
  //at least. How true is it? We'll find out as I run into errors caused by misunderstanding.)
  //So let's head to the move_sub function before coming back to the .onDone.
  inputs.transform(const Utf8Decoder()).transform(const LineSplitter()).listen(move_sub).onDone(() {
    //Ok, coming back from move_sub. .onDone fires after the Stream is finished (ie: the file
    //has been read completely). All that's left to do is print the final position.

    //What's the ! for? Dart is a null-safe language. On lines 48 and 49 I define sub/sub2 as
    //nullable with ?. That means that, on these lines it is theoretically possible for
    //.getFinalPosition to be called on a null object--no bueno. The ! below tells the static
    //type analyzer that I super-duper promise that I have thought about the fact that sub/sub2
    //could be null and I super-duper promise that it's not--so don't bother me about it.
    //(I could also use sub?.getFinalPosition() if I wanted the call to be ignored if sub were
    //null, but given that sub absolutely should not be null here anyway,
    //a crash seems preferred to silent failure.)
    print(sub!.getFinalPosition());
    print(sub2!.getFinalPosition());
  });
}
