/*
 * Copyright contributors to Besu.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 */
pragma solidity 0.8.0;

contract mldsa {
    address private CONTRACT_ADDR = 0x0000000000000000000000000000000000000012;
    uint32 private PKEY_LENGTH = 1312;
    uint32 private SKEY_LENGTH = 2560;
    uint32 private SIG_LENGTH = 2420;
    uint32 private MSG_LENGTH = 100;

    function bytes_concat(bytes memory a, bytes memory b) internal pure returns (bytes memory) {
        bytes memory result = new bytes(a.length + b.length);
        for (uint256 i = 0; i < a.length; i++) {
            result[i] = a[i];
        }
        for (uint256 i = 0; i < b.length; i++) {
            result[i + a.length] = b[i];
        }
        return result;
    }

    function gen_key() public view returns (bytes memory, bytes memory) {
        bytes memory selected_function = hex"debc6bc631"; // the first 5 sha256 bytes of "genKey(bytes)"
        (bool success, bytes memory result) = CONTRACT_ADDR.staticcall(selected_function);
        require(success, "Quantum-Safe Generating Keypairs Failed");

        bytes memory pk = new bytes(PKEY_LENGTH);
        bytes memory sk = new bytes(SKEY_LENGTH);

        for (uint32 i = 0; i < PKEY_LENGTH; i++) {
            pk[i] = result[i];
        }
        for (uint32 i = PKEY_LENGTH; i < PKEY_LENGTH + SKEY_LENGTH; i++) {
            sk[i - PKEY_LENGTH] = result[i];
        }

        return (pk, sk);
    }

    function sign(bytes memory sk, bytes memory message) public view returns (bytes memory, bytes memory) {
        bytes memory selected_function = hex"47c0112cea"; // the first 5 sha256 bytes of "sign(bytes)"

        if (message.length > MSG_LENGTH) {
            // Message too large!
            return (hex"00", hex"00");
        }

        if (message.length < MSG_LENGTH) {
            bytes memory padd = new bytes(MSG_LENGTH - message.length);
            for (uint32 i = 0 ; i < padd.length; i++) {
                padd[i] = hex"00"; // Padding
            }
            message = bytes_concat(message, padd);
        }

        (bool success, bytes memory result) = CONTRACT_ADDR.staticcall(bytes_concat(bytes_concat(selected_function, sk), message));
        require(success, "Quantum-Safe Signing Failed");

        bytes memory sig = new bytes(SIG_LENGTH);
        bytes memory sig_length = new bytes(8);

        for (uint32 i = 0; i < SIG_LENGTH; i++) {
            sig[i] = result[i];
        }
        for (uint32 i = SIG_LENGTH; i < SIG_LENGTH + 8; i++) {
            sig_length[i - SIG_LENGTH] = result[i];
        }

        return (sig, sig_length);
    }

    function verify(bytes memory pk, bytes memory message, bytes memory sig) public view returns (bool) {
        bytes memory selected_function = hex"485882aa35"; // the first 5 sha256 bytes of "verify(bytes)"

        if (message.length > MSG_LENGTH) {
            // Message too large!
            return false;
        }
        if (message.length < MSG_LENGTH) {
            bytes memory padd = new bytes(MSG_LENGTH - message.length);
            for (uint32 i = 0 ; i < padd.length; i++) {
                padd[i] = hex"00"; // Padding
            }
            message = bytes_concat(message, padd);
        }

        (bool success, bytes memory result) = CONTRACT_ADDR.staticcall(bytes_concat(bytes_concat(bytes_concat(selected_function, pk), message), sig));
        require(success, "Quantum-Safe Verifying Failed");

        return result[0] != 0x00;
    }
}
