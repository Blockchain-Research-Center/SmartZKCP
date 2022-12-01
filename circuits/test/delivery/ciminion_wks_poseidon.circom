pragma circom 2.0.3;

include "../../enc/ciminion-wks/ciminion_enc.circom";
include "../../hash/poseidon/poseidon.circom";

template Enc(nPairs) {
    
    signal input Keys[nPairs*2+3];
    signal input PT[nPairs*2];
    signal CT[nPairs*2];
    signal output Out;

    component ciminion_enc = CiminionEnc(nPairs);

    for(var i=0;i<nPairs*2;i++){
        ciminion_enc.PT[i] <== PT[i];
        ciminion_enc.Keys[i] <== Keys[i];
    }
    
    ciminion_enc.Keys[nPairs*2] <== Keys[nPairs*2];
    ciminion_enc.Keys[nPairs*2+1] <== Keys[nPairs*2+1];
    ciminion_enc.Keys[nPairs*2+2] <== Keys[nPairs*2+2];

    var poseidonCount = (nPairs*2-1)\15;
    var rest = (nPairs*2-1)%15;

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

component main {public [Keys]} = CiminionEnc(500);