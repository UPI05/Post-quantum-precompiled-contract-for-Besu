from web3 import Web3
import hashlib
import struct

URL = "http://127.0.0.1:8545"
CONTRACT_ADDR = "0x0000000000000000000000000000000000000014"
PKEY_LENGTH = 2592 
SKEY_LENGTH = 4896 
SIG_LENGTH = 4627 
MSG_LENGTH = 100


def convert_bytes_to_size_t(byte_string):
    # Sử dụng struct để chuyển đổi từ mảng byte string 8 byte thành một số nguyên size_t
    return struct.unpack("<Q", byte_string)[0]  # '<Q' cho little-endian, 8 byte unsigned long long

def call_contract(data, function_selector):
    # get hash value of the objective function
    hash_object = hashlib.sha256(function_selector.encode())
    fn_hash = hash_object.hexdigest()[:10]

    tx = {
        "to": CONTRACT_ADDR,
        "data": fn_hash + data.hex(),
    }
    result = web3.eth.call(tx)
    return result

def call_genKeyFn():
    res = call_contract(b"", "genKey(bytes)").hex()
    pkey = res[:PKEY_LENGTH * 2]
    skey = res[PKEY_LENGTH * 2:]
    return pkey, skey

def call_sign(msg, skey):
    res = call_contract(skey + msg, "sign(bytes)")
    return res[:SIG_LENGTH], convert_bytes_to_size_t(res[SIG_LENGTH:])

def call_verify(msg, pkey, sig):
    res = call_contract(pkey + msg + sig, "verify(bytes)")
    return res


if __name__ == "__main__":
    web3 = Web3(Web3.HTTPProvider(URL))
    opt = int(input("Type '1' for Generating keypairs, '2' for Signing and '3' for Verifying: "))
    
    if opt == 1:
        pkey, skey = call_genKeyFn()
        print(f"Public key: {pkey}")
        print("========================================")
        print(f"Secret key: {skey}")
        print("++++++++++++++++++++++++++++++++++++++++")
        print(f"Pkey size (bytes): {len(pkey) / 2} / Skey size (bytes): {len(skey) / 2  }")

    elif opt == 2:
        msg = input("Message: ")
        msg = msg.encode('UTF-8') + b'\x00' * (MSG_LENGTH - len(msg))
        
        path = input("Secret key path: ")
        skey = ''
        with open(path, 'r') as file:
            skey = file.read()
        
        sig, sig_length = call_sign(msg, bytes.fromhex(skey))

        print(f"Signature: {sig.hex()}")
        print(f"Sig length: {sig_length}")
    elif opt == 3:
        msg = input("Message: ")
        msg = msg.encode('UTF-8') + b'\x00' * (MSG_LENGTH - len(msg))
        
        path = input("Public key path: ")
        pkey = ''
        with open(path, 'r') as file:
            pkey = file.read()

        path = input("Signature path: ")
        signature = ''
        with open(path, 'r') as file:
            signature = file.read()
        
        res = call_verify(msg, bytes.fromhex(pkey), bytes.fromhex(signature))

        print(f"Verify status: {res}")
    else:
        print("Invalid option!")
