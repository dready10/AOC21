import 'dart:io';

const int boardSize = 5;

class BoardSpace {
  int number;
  bool seen;

  BoardSpace(this.number, this.seen);
  bool operator ==(Object i) {
    return number == i;
  }

  String toString() {
    return "$number: $seen";
  }
}

bool checkRows(List<BoardSpace> board) {
  bool victory = true;
  for (int row = 0; row < boardSize; row++) {
    for (int i = 0; i < boardSize; i++) {
      victory &= board[row * boardSize + i].seen;
    }
    if (victory) return true;
    victory = true;
  }
  return false;
}

bool checkColumns(List<BoardSpace> board) {
  bool victory = true;
  for (int col = 0; col < boardSize; col++) {
    for (int i = 0; i < boardSize; i++) {
      victory &= board[i * boardSize + col].seen;
    }
    if (victory) return true;
    victory = true;
  }
  return false;
}

bool checkDiagonals(List<BoardSpace> board) {
  for (int diag = 0; diag < boardSize; diag++) {
    if (!board[diag * boardSize + diag].seen) {
      return false;
    }
  }
  for (int diag = boardSize - 1; diag >= 0; diag--) {
    if (!board[(boardSize - diag) * diag].seen) {
      return false;
    }
  }
  return true;
}

int calculateBoardScore(List<BoardSpace> board) {
  int total = 0;
  board.forEach((number) {
    if (!number.seen) total += number.number;
  });
  return total;
}

bool checkBoard(List<BoardSpace> board) {
  return checkRows(board) || checkColumns(board) || checkDiagonals(board);
}

void markSeen(List<BoardSpace> board, int i) {
  for (BoardSpace space in board) if (space == i) space.seen = true;
}

void main() {
  List<String> input = File('day4.txt').readAsStringSync().split('\r\n\r\n');
  Iterable<int> draws = input[0].split(',').map((i) => int.parse(i));

  // So I chose to represent my boards just as a list instead of as a matrix.
  // Position [0, 0] on the board is just position 0 in the list. [1, 0] is 1,
  // and [0, 1] is 1 * size_of_board + x.
  // This line takes each board (sublist(1)), puts them all into lists
  // (.split(\r\n).join(' ').split('') of integers (.map((i)).toList)
  // The ..retainWhere is some cool syntatic sugar where I can make the target
  // of the operation (retainWhere) be the target of the previous statement.
  // So I'm saying "in this list of stuff I just created, retain only non-blanks"
  List<List<BoardSpace>> boards = input
      .sublist(1)
      .map((board) => board
          .split('\r\n')
          .join(' ')
          .split(RegExp(' +'))
          .map((i) => BoardSpace(int.parse(i == '' ? '-1' : i), false))
          .toList()
        ..retainWhere((e) => e != -1))
      .toList();

  // Now we keep track of the order in which the boards win and the score at
  // the time the board became a winner.
  List<int> winningOrder = [];
  List<int> winningScores = [];
  drawsLoop: // The only remaining valid use of GoTo.
  for (int draw in draws) {
    for (int i = 0; i < boards.length; i++) {
      markSeen(boards[i], draw);
      if (!winningOrder.contains(i) && checkBoard(boards[i])) {
        winningOrder.add(i);
        winningScores.add(calculateBoardScore(boards[i]) * draw);
      }
    }
  }
  //part 1
  print(winningScores.first);

  //part 2
  print(winningScores.last);
}
