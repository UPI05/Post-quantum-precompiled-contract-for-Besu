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
        string mlKemEncapKey;
        string id;
        uint256 creationTime;
        uint256 expirationTime;
        string ipAddress;
    }

    // Mapping from id to VerificationObject
    mapping(string => VerificationObject) private objects;

    // Mapping to check if ID exists
    mapping(string => bool) private idExists;

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addObject(
        string memory _mlKemEncapKey,
        string memory _id,
        uint256 _creationTime,
        uint256 _expirationTime,
        string memory _ipAddress
    ) public onlyOwner {
        require(!idExists[_id], "ID already exists");
        require(_creationTime < _expirationTime, "Expiration time must be after creation time");

        objects[_id] = VerificationObject({
            mlKemEncapKey: _mlKemEncapKey,
            id: _id,
            creationTime: _creationTime,
            expirationTime: _expirationTime,
            ipAddress: _ipAddress
        });

        idExists[_id] = true;
    }

    function getObject(string memory _id)
        public
        view
        returns (
            string memory mlKemEncapKey,
            uint256 creationTime,
            uint256 expirationTime,
            string memory ipAddress
        )
    {
        require(idExists[_id], "ID does not exist");

        VerificationObject memory obj = objects[_id];
        return (
            obj.mlKemEncapKey,
            obj.creationTime,
            obj.expirationTime,
            obj.ipAddress
        );
    }
}