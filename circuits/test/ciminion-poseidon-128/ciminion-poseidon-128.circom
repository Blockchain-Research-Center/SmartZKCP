pragma circom 2.0.3;

include "../../ciminion/ciminion_enc.circom";
include "../../circuits/poseidon.circom";

template Enc(blockSize) {
    signal input MK_0;
    signal input MK_1;

    signal input in[blockSize*2];
    signal CT[blockSize*2];
    signal output out;

    component ciminion_enc = CiminionEnc(blockSize);

    ciminion_enc.MK_0 <== MK_0; 
    ciminion_enc.MK_1 <== MK_1; 
    ciminion_enc.nonce <== 0; 
    ciminion_enc.IV <== 0; 

    for(var i=0;i<blockSize*2;i++){
        ciminion_enc.PT[i] <== in[i]; 
    }
    
    for(var i=0;i<blockSize*2;i++){
        CT[i] <== ciminion_enc.CT[i];
    }

    var poseidonCount = (blockSize*2-1)\15;
    var rest = (blockSize*2-1)%15;

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
        out <== last.out;
    } else {
        out <== hash[poseidonCount-1].out;
    }
}

// component main = Enc(512);