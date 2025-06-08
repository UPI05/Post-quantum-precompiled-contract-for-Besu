const { Web3 } = require('web3');
const fs = require('fs');
const path = require('path');
const readline = require('readline');
const fas = require('fs').promises;

// Create interface for reading from stdin and writing to stdout
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

async function call(
    selected_function,
    host,
    deployedContractAbi,
    deployedContractAddress,
  ) {
    const web3 = new Web3(host);
    const contractInstance = new web3.eth.Contract(
      deployedContractAbi,
      deployedContractAddress,
    );
    
    if (selected_function == 1) {
      const keypair= await contractInstance.methods.gen_key().call();
      console.log("Public key: " + keypair[0] + "\n");
      console.log("Secret key: " + keypair[1]);

    } else if (selected_function == 2) {
      rl.question("Type secret key path: ", async (path) => {
        const sk = await fas.readFile(path, 'utf8');
        rl.question("Type message to sign: ", async (msg) => {
          const sig= await contractInstance.methods.sign(Buffer.from(sk, 'hex'), Buffer.from(msg, 'utf-8')).call();
          console.log("Signature: " + sig[0] + "\n");
          console.log("Signature length: " + sig[1])
        });
      });

    } else if (selected_function == 3) {
      rl.question("Type public key path: ", async (path) => {
        const pk = await fas.readFile(path, 'utf8');
        rl.question("Type signature path: ", async (path) => {
          const sig = await fas.readFile(path, 'utf8');
          rl.question("Type message to verify: ", async (msg) => {
            const result = await contractInstance.methods.verify(Buffer.from(pk, 'hex'), Buffer.from(msg, 'utf-8'), Buffer.from(sig, 'hex')).call();
            console.log("Result: " + result);
          });
        });
      });
    } else {
      console.log("Invalid option!");
    }
    
  }

function main() {
  //const abi = JSON.parse(fs.readFileSync('mldsa.abi', 'utf8'));
  const contractJsonPath = path.resolve(__dirname, "MLDSA65.json");
  const contractJson = JSON.parse(fs.readFileSync(contractJsonPath));
  const abi = contractJson.abi;

  rl.question("Type '1' for generating keypairs, '2' for signing a message an '3' for verifying: ", (opt) => {
    call(opt, "http://127.0.0.1:8545", abi, "0x99e0fe804acb6178658eb78d1bff2bd0d12f252a");
  });
}

main();
