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

contract VerificationContract {
    struct VerificationObject {
        string x509Certificate;
        string commonName;
        string ipAddress;
    }

    // Mapping from commonName to VerificationObject
    mapping(string => VerificationObject) private objects;

    mapping(string => bool) private commonNameExists;

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addObject(
        string memory _x509Certificate,
        string memory _commonName,
        string memory _ipAddress
    ) public onlyOwner {
        require(!commonNameExists[_commonName], "Common Name already exists");

        objects[_commonName] = VerificationObject({
            x509Certificate: _x509Certificate,
            commonName: _commonName,
            ipAddress: _ipAddress
        });

        commonNameExists[_commonName] = true;
    }

    function getObject(string memory _commonName)
        public
        view
        returns (
            string memory x509Certificate,
            string memory commonName,
            string memory ipAddress
        )
    {
        require(commonNameExists[_commonName], "Common Name does not exist");

        VerificationObject memory obj = objects[_commonName];
        return (obj.x509Certificate, obj.commonName, obj.ipAddress);
    }
}