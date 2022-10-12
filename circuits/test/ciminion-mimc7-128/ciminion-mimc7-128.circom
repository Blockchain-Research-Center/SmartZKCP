pragma circom 2.0.3;

include "../../ciminion/ciminion_enc.circom";
include "../../circuits/mimc.circom";

template Enc(blockSize) {

    signal input MK_0;
    signal input MK_1;
    signal input nonce;
    signal input IV;

    signal input in[blockSize*2];
    // signal CT[blockSize*2];
    signal output out;

    component ciminion_enc = CiminionEnc(blockSize);

    ciminion_enc.MK_0 <== MK_0; 
    ciminion_enc.MK_1 <== MK_1; 
    ciminion_enc.nonce <== nonce; 
    ciminion_enc.IV <== IV; 

    for(var i=0;i<blockSize*2;i++){
        ciminion_enc.PT[i] <== in[i]; 
    }
    
    // for(var i=0;i<blockSize*2;i++){
    //     CT[i] <== ciminion_enc.CT[i];
    // }

    component mimc = MultiMiMC7(blockSize*2, 91);

    mimc.k <== 0x1234567;

    for(var i=0;i<blockSize*2;i++){
        mimc.in[i] <== ciminion_enc.CT[i];
    }

    out <== mimc.out;
}

// component main = Enc(512);