pragma circom 2.0.3;

include "../../enc/ciminion-ks/ciminion_enc.circom";
include "../../hash/poseidon/poseidon.circom";

template Enc(nPairs) {
    
    signal input MK_0;
    signal input MK_1;
    signal input PT[nPairs*2];
    signal CT[nPairs*2];
    signal output Out;

    component ciminion_enc = CiminionEnc(nPairs);

    ciminion_enc.MK_0 <== MK_0; 
    ciminion_enc.MK_1 <== MK_1; 
    

    for(var i=0;i<nPairs*2;i++){
        ciminion_enc.PT[i] <== PT[i]; 
    }
    
    for(var i=0;i<nPairs*2;i++){
        CT[i] <== ciminion_enc.CT[i];
    }

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

component main {public [MK_0, MK_1]} = Enc(50);