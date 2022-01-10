// Check to see if the initial velocity x and y eventually
// hit the target.
bool hitsTarget(int x, int y, minX, maxX, minY, maxY) {
  List<int> start = [0, 0];
  while (start[1] > minY && start[0] < maxX) {
    start[0] += x;
    start[1] += y;
    x = x - 1 < 0 ? 0 : x - 1;
    y -= 1;
    if (minX <= start[0] && start[0] <= maxX && minY <= start[1] && start[1] <= maxY) {
      return true;
    }
  }
  return false;
}

void main() {
  // Puzzle input
  int minX, maxX, minY, maxY;
  minX = 60;
  maxX = 94;
  minY = -171;
  maxY = -136;

  //Honestly, let's just brute-force it. Only takes a few seconds, and it works.
  //Reasonable bounds are enforced by the inputs. We know that y velocity ("y")
  //won't exceed +178 because the min Y is -176. Because the velocity of y
  //just steadily decrements from its intitial value, it forms an arc such that
  //the y velocity of the probe is equal to the negative initial value when it
  //hits the water line. (Also just thinking about it in physics terms, this
  //is obviously true when ignoring drag. A ball thrown upwards will have the
  //same down velocity at some time t > 0 as upwards velocity it had at t = 0.
  //And obviously x can't be above maxX otherwise you'll just skip right over it.
  int total = 0;
  List<int> best = [-1, -1000];
  for (int x = 1; x <= maxX; x++) {
    print("Testing x as $x");
    for (int y = minY; y < 178; y++) {
      if (hitsTarget(x, y, minX, maxX, minY, maxY)) {
        total += 1;
        if (y > best[1]) {
          best = [x, y];
        }
      }
    }
  }

  print((best[1] + 1) * best[1] / 2);
  print(total);
}
