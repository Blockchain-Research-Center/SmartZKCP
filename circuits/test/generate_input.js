const { randomInt } = require('crypto');
json = {in:[]};
for(let i=0;i<512;i++){
    json['in'][i] = randomInt(2);
}
let fs = require('fs');
fs.writeFile('input.json', JSON.stringify(json), 'utf8', ()=>{});