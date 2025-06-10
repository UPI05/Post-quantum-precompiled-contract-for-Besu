const { Web3 } = require('web3');
const fs = require('fs');
const path = require('path');

async function main() {

    const host = 'http://127.0.0.1:8545'; // Replace with your host
    const web3 = new Web3(host);
    const privateKey =
    "0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f";
    const account = web3.eth.accounts.privateKeyToAccount(privateKey);
    const name = "VerificationContract";

    // read in the contracts
    const contractJsonPath = path.resolve(__dirname, name + ".json");
    const contractJson = JSON.parse(fs.readFileSync(contractJsonPath));
    const contractAbi = contractJson.abi;
    const contractBin = contractJson.bytecode;

    // initialize the default constructor with a value `47 = 0x2F`; this value is appended to the bytecode
    const contractConstructorInit =
    "000000000000000000000000000000000000000000000000000000000000002F";

    // get txnCount for the nonce value
    const txnCount = await web3.eth.getTransactionCount(account.address);

    const txn = {
        chainId: 1337,
        nonce: web3.utils.numberToHex(txnCount),
        from: account.address,
        to: null,
        value: "0x00",
        data: "0x" + contractBin + contractConstructorInit, // contract binary appended with initialization value
        gasPrice: "0x0", //ETH per unit of gas
        gasLimit: "0x444444", //max number of gas units the tx is allowed to use
    };
    console.log("Creating transaction and sign...");
    const signedTx = await web3.eth.accounts.signTransaction(txn, account.privateKey);
    console.log("Sending transaction...");
    const pTx = await web3.eth.sendSignedTransaction(signedTx.rawTransaction);
    console.log("tx transactionHash: " + pTx.transactionHash);
    console.log("tx contractAddress: " + pTx.contractAddress);
}

main();
