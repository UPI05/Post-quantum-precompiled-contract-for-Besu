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
    privateKey,
    deployedContractAbi,
    deployedContractAddress,
  ) {
    const web3 = new Web3(host);
    const contractInstance = new web3.eth.Contract(
      deployedContractAbi,
      deployedContractAddress,
    );
    
    if (selected_function == 1) {
      rl.question("Type cert path: ", async (path) => {
        const crt = await fas.readFile(path, 'utf8');
        rl.question("Type CNAME: ", async (cname) => {
          rl.question("Type IP: ", async (ip) => {
            const web3 = new Web3(host);
            const account = web3.eth.accounts.privateKeyToAccount(privateKey);

            // Tạo instance contract
            const contract = new web3.eth.Contract(deployedContractAbi, deployedContractAddress);

            // Encode lời gọi hàm
            const data = contract.methods.set(crt, cname, ip).encodeABI();

            // Lấy nonce
            const nonce = await web3.eth.getTransactionCount(account.address, "pending");

            // Tạo raw transaction
            const tx = {
              chainId: 1337,
              nonce: web3.utils.toHex(nonce),
              to: deployedContractAddress,
              data: data,
              gas: "0x24A22", // hoặc tùy chỉnh
              gasPrice: "0xFF", // Besu không cần cao
              value: "0x0",
            };

            // Ký giao dịch
            const signedTx = await web3.eth.accounts.signTransaction(tx, privateKey);

            // Gửi giao dịch
            const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);

            // Trả về thông tin giao dịch
            console.log("receipt:" + receipt);
          });
        });
      });

    } else if (selected_function == 2) {
      rl.question("Type CNAME: ", async (cname) => {
        const res = await contractInstance.methods.getObject(Buffer.from(cname, 'utf-8')).call();
        console.log("Cert: " + res[0] + "\n")
        console.log("Cname: " + res[1] + "\n")
        console.log("IP: " + res[2] + "\n")
      });
    } else {
      console.log("Invalid option!");
    }
    
  }

function main() {
  //const abi = JSON.parse(fs.readFileSync('mldsa.abi', 'utf8'));
  const contractJsonPath = path.resolve(__dirname, "VerificationContract.json");
  const contractJson = JSON.parse(fs.readFileSync(contractJsonPath));
  const abi = contractJson.abi;
  const pkey = "";

  rl.question("Type '1' for adding objects, '2' for getting objects:", (opt) => {
    call(opt, "http://127.0.0.1:8545", pkey, abi, "0x3c9687d86a4a93b9106df5b1abcc3a83c9831ce1");
  });
}

main();
