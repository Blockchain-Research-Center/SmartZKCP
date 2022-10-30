pragma circom 2.0.3;

template Main(SIZE, SUBSIZE) {
  
  signal input solved_grid[SIZE * SIZE];
  signal output out;
  var flag = 1;

  var rows[SIZE][SIZE];
  var cols[SIZE][SIZE];
  var boxs[SIZE][SIZE];

  for (var i = 0; i < SIZE; i++) {
    for (var j = 0; j < SIZE; j++) {
      var num = solved_grid[i * SIZE + j] - 1;
      var boxIndex = (i \ SUBSIZE) * SUBSIZE + j \ SUBSIZE;
      log("boxIndex is ", boxIndex ,"num is", num);
      if (rows[i][num] == 1) {
        flag = 0;
      }
      rows[i][num] = 1;
      if (cols[j][num] == 1) {
        flag = 0;
      }
      cols[j][num] = 1;
      if (boxs[boxIndex][num] == 1) {
        flag = 0;
      }
      boxs[boxIndex][num] = 1;
    }
  }

  //out <== flag;

}

//component main = Main(16, 4);