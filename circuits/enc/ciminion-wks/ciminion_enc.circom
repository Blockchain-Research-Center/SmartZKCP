pragma circom 2.0.6;

include "permutation.circom";
include "rolling.circom";

template CiminionEnc(nPairs) {

    signal input Keys[nPairs*2+3];
    signal input PT[nPairs*2];
    signal output CT[nPairs*2];

    component p_n = IteratedPermutationN();
    p_n.a0 <== 0;
    p_n.b0 <== Keys[1];
    p_n.c0 <== Keys[2];

    component rolls[nPairs];
    component p_rs[nPairs];

    for (var i = 0; i < nPairs; i++) {
    
        rolls[i] = Rolling();

        if (i == 0) {
            rolls[i].s0 <== p_n.a1 + Keys[2*i + 4];
            rolls[i].s1 <== p_n.b1 + Keys[2*i + 3];
            rolls[i].s2 <== p_n.c1;
        } else {   
            rolls[i].s0 <== rolls[i-1].b0 + Keys[2*i + 4];
            rolls[i].s1 <== rolls[i-1].b1 + Keys[2*i + 3];
            rolls[i].s2 <== rolls[i-1].b2;
        }

        p_rs[i] = IteratedPermutationR();

        p_rs[i].a0 <== rolls[i].b0;
        p_rs[i].b0 <== rolls[i].b1;
        p_rs[i].c0 <== rolls[i].b2;

        CT[2*i] <== p_rs[i].a1 + PT[2*i];
        CT[2*i + 1] <== p_rs[i].b1 + PT[2*i + 1];

    }
}

//component main {public [Keys]} = CiminionEnc(50);