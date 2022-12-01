pragma circom 2.0.6;

include "../../enc/hadesmimc/hadesmimc.circom";
include "../../hash/poseidon/poseidon.circom";

template Enc(n) {

    signal input PT[n];
    signal input Keys[16];
    signal CT[n];
    signal output Out;

    component mimc = MiMC5n(n, 71, 6);

    for(var i=0;i<n;i++){
        mimc.p[i] <== PT[i];
        mimc.k[i] <== Keys[i%16];
    }
    
    for(var i=0;i<n;i++){
        CT[i] <== mimc.c[i];
    }

    var poseidonCount = (n-1)\15;
    var rest = (n-1)%15;

    component hash[poseidonCount];

    for(var i=0;i<poseidonCount;i++){
        hash[i] = Poseidon(16);
        if(i==0){
            for(var j=0;j<16;j++){
                hash[i].inputs[j] <== CT[j];
            }
        } else {
            hash[i].inputs[0] <== hash[i-1].out;
            for(var j=1;j<16;j++){
                hash[i].inputs[j] <== CT[i*15+j];
            }
        }
    }
    component last;
    if(rest!=0){
        last = Poseidon(rest+1);
        last.inputs[0] <== hash[poseidonCount-1].out;
        for(var i=0;i<rest;i++){
            last.inputs[i+1] <== CT[poseidonCount*15+1+i];
        }
        Out <== last.out;
    } else {
        Out <== hash[poseidonCount-1].out;
    }
}

//component main {public [Keys]} = Enc(10000);