pragma circom 2.0.8;

include "../ciminion-poseidon-128/ciminion-poseidon-128.circom";
include "sudoku.circom";

template top(){
    signal input MK_0;
    signal input MK_1;
    signal input nonce;
    signal input IV;
    signal input solution[1296];
    signal input expectedHash;
    component sudoku = Main(36,6);
    for(var i=0;i<36;i++){
        for(var j=0;j<36;j++){
            sudoku.unsolved_grid[i][j] <== solution[i*16+j];
            sudoku.solved_grid[i][j] <== solution[i*16+j];
        }
    }
    component hash = Enc(1296\2);
    hash.MK_0 <== MK_0;
    hash.MK_1 <== MK_1;
    hash.nonce <== nonce;
    hash.IV <== IV;
    for(var i=0;i<1296;i++){
        hash.in[i] <== solution[i];
    }
    expectedHash === hash.out;
}

component main = top();