pragma circom 2.0.6;

include "comparators.circom";
include "gates.circom";

template InRange(bits) {
  signal input value;
  signal input lower;
  signal input upper;
  signal output out;

  component upperBound = LessEqThan(bits);
  upperBound.in[0] <== value;
  upperBound.in[1] <== upper;

  component lowerBound = GreaterEqThan(bits);
  lowerBound.in[0] <== value;
  lowerBound.in[1] <== lower;

  out <== upperBound.out*lowerBound.out;
}

template ContainsAll(SIZE) {
  signal input in[SIZE];

  component is_equal[SIZE][SIZE];
  for (var i = 0;i < SIZE;i++) {
    for (var j = 0;j < SIZE;j++) {
      is_equal[i][j] = IsEqual();
    }
  }

  for (var i = 0;i < SIZE;i++) {
    for (var j = 0;j < SIZE;j++) {
      is_equal[i][j].in[0] <== in[i];
      is_equal[i][j].in[1] <== (i == j) ? 0 : in[j];
      is_equal[i][j].out === 0;
    }
  }
}

template Check(SIZE, SUBSIZE) {

  signal input solved_grid[SIZE][SIZE];

  component range_checkers[SIZE][SIZE];
  component row_checkers[SIZE];
  component col_checkers[SIZE];
  component submat_checkers[SIZE];
  for (var i = 0;i < SIZE;i++) {
    row_checkers[i] = ContainsAll(SIZE);
    col_checkers[i] = ContainsAll(SIZE);
    submat_checkers[i] = ContainsAll(SIZE);
    for (var j = 0;j < SIZE;j++) {
      range_checkers[i][j] = InRange(4);
    }
  }

  // Assert input grids are valid and solved grid matches unsolved grid
  for (var i = 0;i < SIZE;i++) {
    for (var j = 0;j < SIZE;j++) {
      range_checkers[i][j].value <== solved_grid[i][j];
      range_checkers[i][j].upper <== SIZE;
      range_checkers[i][j].lower <== 1;
      range_checkers[i][j].out === 1;
    }
  }

  // Check rows
  for (var i = 0;i < SIZE;i++) {
    for (var j = 0;j < SIZE;j++) {
      row_checkers[i].in[j] <== solved_grid[i][j];
    }
  }

  // Check columns
  for (var i = 0;i < SIZE;i++) {
    for (var j = 0;j < SIZE;j++) {
      col_checkers[i].in[j] <== solved_grid[j][i];
    }
  }

  // Check submatrices
  for (var i = 0;i < SIZE;i += SUBSIZE) {
    for (var j = 0;j < SIZE;j += SUBSIZE) {
      for (var k = 0;k < SUBSIZE;k++) {
        for (var l = 0;l < SUBSIZE;l++) {
          submat_checkers[i + j / SUBSIZE].in[k*SUBSIZE + l] <== solved_grid[i + k][j + l];
        }
      }
    }
  }
}

//component main = Main(16, 4);