const { Web3 } = require('web3');
const fs = require('fs');

async function getValueAtAddress(
    host,
    deployedContractAbi,
    deployedContractAddress,
  ) {
    const web3 = new Web3(host);
    const contractInstance = new web3.eth.Contract(
      deployedContractAbi,
      deployedContractAddress,
    );
    const res = await contractInstance.methods.get().call();
    console.log("Obtained value at deployed contract is: " + res);
    return res;
  }

function main() {
    const abi = JSON.parse(fs.readFileSync('SimpleStorage.abi', 'utf8'));
    getValueAtAddress("http://127.0.0.1:8545", abi, "0x3c9687d86a4a93b9106df5b1abcc3a83c9831ce1");
}

main();