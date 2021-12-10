import 'dart:collection';
import 'dart:io';

void main() {
  //There is probably a more compact way to do this, but this is easy-to-read and
  //straightforward, so I am going with it.
  Map<String, int> p1char_vals = Map();
  p1char_vals[')'] = 3;
  p1char_vals[']'] = 57;
  p1char_vals['}'] = 1197;
  p1char_vals['>'] = 25137;

  Map<String, int> p2char_vals = Map();
  p2char_vals['('] = 1;
  p2char_vals['['] = 2;
  p2char_vals['{'] = 3;
  p2char_vals['<'] = 4;

  Map<String, String> matches = Map();
  matches[')'] = '(';
  matches[']'] = '[';
  matches['}'] = '{';
  matches['>'] = '<';

  int part1score = 0;
  List p2Scores = [];

  List lines = File('day10.txt').readAsLinesSync();
  lineLoop: // To jump back to when we see a corrupt line (don't want to include it in part 2)
  for (String line in lines) {
    ListQueue<String> queue = ListQueue();

    // For each symbol, if it's an opening symbol, add it to the queue.
    // If it's a closing symbol it must match whatever's at the end of the LQ.
    // If it matches, great, we pull the opener off the queue (queue.removeLast()).
    // If it doesn't, match, we have a corrupt line, so add it to the score and then start the next line.
    List<String> symbols = line.split('');
    for (String symbol in symbols) {
      if (['(', '[', '{', '<'].contains(symbol))
        queue.add(symbol);
      else {
        if (matches[symbol] != queue.last) {
          // Found a corrupt line
          part1score += p1char_vals[symbol] ?? 0;
          continue lineLoop;
        } else {
          queue.removeLast();
        }
      }
    }

    // If we arrived here, it's an incomplete line. Whatever remains in the queue
    // are the unmatched brackets. So we just pull them off the queue and tally
    // up what we need, then take the median value for part 2.
    int score = 0;
    while (queue.isNotEmpty) {
      score *= 5;
      score += p2char_vals[queue.last] ?? 0;
      queue.removeLast();
    }
    p2Scores.add(score);
  }
  print(part1score);
  print((p2Scores..sort())[(p2Scores.length / 2).floor()]);
}
