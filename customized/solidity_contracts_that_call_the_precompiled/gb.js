const {Web3} = require('web3');

const web3 = new Web3('http://127.0.0.1:8545');

const privateKey = '0xc87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3'; // Replace with your private key

const account = web3.eth.accounts.privateKeyToAccount(privateKey);
console.info(account);

async function getBalance() {

	  try {

		      const balanceWei = await web3.eth.getBalance(account.address);

//		      const balanceEth = web3.utils.fromWei(balanceWei, 'ether');

		      console.log(`Balance of account ${account.address}: ${balanceWei} Wei`);

		    } catch (error) {

			        console.error('Error fetching balance:', error);

			      }

}



getBalance();
