from web3 import Web3
import json
import os

def get_object(host, contract_address, abi_path):
    # Kết nối đến node Ethereum
    web3 = Web3(Web3.HTTPProvider(host))

    # Tải ABI từ file JSON
    with open(abi_path, 'r') as abi_file:
        contract_json = json.load(abi_file)
        abi = contract_json['abi']

    # Tạo instance của contract
    contract = web3.eth.contract(address=contract_address, abi=abi)

    # Nhập ID cần truy vấn
    object_id = input("Type ID: ")

    # Gọi hàm getObject
    try:
        result = contract.functions.getObject(object_id).call()
        print("Encap key:", result[0])
        print("Creation time:", result[1])
        print("Expiration time:", result[2])
        print("IP:", result[3])
    except Exception as e:
        print("Error calling contract:", e)

if __name__ == "__main__":
    HOST = "http://127.0.0.1:8545"
    CONTRACT_ADDRESS = "0x3c9687d86a4a93b9106df5b1abcc3a83c9831ce1"
    ABI_PATH = os.path.join(os.path.dirname(__file__), "VerificationContract.json")

    get_object(HOST, CONTRACT_ADDRESS, ABI_PATH)
