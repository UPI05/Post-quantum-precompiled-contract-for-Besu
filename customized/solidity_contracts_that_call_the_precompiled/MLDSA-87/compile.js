const fs = require("fs").promises;
const solc = require("solc");

async function main() {
  const name = "MLDSA87"
  // Load the contract source code
  const sourceCode = await fs.readFile(name + ".sol", "utf8");
  // Compile the source code and retrieve the ABI and bytecode
  const { abi, bytecode } = compile(sourceCode, name);
  // Store the ABI and bytecode into a JSON file
  const artifact = JSON.stringify({ abi, bytecode }, null, 2);
  await fs.writeFile(name + ".json", artifact);
}

function compile(sourceCode, contractName) {
    const input = {
      language: "Solidity",
      sources: { main: { content: sourceCode } },
      settings: { outputSelection: { "*": { "*": ["abi", "evm.bytecode"] } } },
    };
    const output = solc.compile(JSON.stringify(input));
    const parsedOutput = JSON.parse(output);
  
    if (parsedOutput.errors) {
      console.error("Lỗi biên dịch:", parsedOutput.errors);
      throw new Error("Biên dịch thất bại");
    }
  
    const contracts = parsedOutput.contracts;
    if (!contracts || !contracts.main) {
      throw new Error("Không có hợp đồng nào được biên dịch.");
    }
  
    const artifact = contracts.main[contractName];
    if (!artifact) {
      throw new Error(`Không tìm thấy hợp đồng "${contractName}"`);
    }
  
    return {
      abi: artifact.abi,
      bytecode: artifact.evm.bytecode.object,
    };
  }

main().then(() => process.exit(0));
