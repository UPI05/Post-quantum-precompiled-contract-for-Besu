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
    // Định nghĩa cấu trúc cho đối tượng xác thực
    struct VerificationObject {
        string x509Certificate; // Chứng chỉ X.509
        string commonName;      // Common Name (CN)
        string ipAddress;       // Địa chỉ IP
    }

    // Mapping từ commonName sang VerificationObject
    mapping(string => VerificationObject) private objects;

    // Lưu danh sách các commonName để kiểm tra trùng lặp
    mapping(string => bool) private commonNameExists;

    // Địa chỉ của account deploy hợp đồng
    address private owner;

    // Modifier để giới hạn chỉ owner được gọi hàm
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can call this function");
        _;
    }

    // Constructor để gán owner khi deploy
    constructor() {
        owner = msg.sender;
    }

    // Hàm thêm đối tượng xác thực
    function addObject(
        string memory _x509Certificate,
        string memory _commonName,
        string memory _ipAddress
    ) public onlyOwner {
        // Kiểm tra commonName đã tồn tại chưa
        require(!commonNameExists[_commonName], "Common Name already exists");

        // Lưu đối tượng vào mapping
        objects[_commonName] = VerificationObject({
            x509Certificate: _x509Certificate,
            commonName: _commonName,
            ipAddress: _ipAddress
        });

        // Đánh dấu commonName đã tồn tại
        commonNameExists[_commonName] = true;
    }

    // Hàm lấy thông tin đối tượng bằng commonName
    function getObject(string memory _commonName)
        public
        view
        returns (
            string memory x509Certificate,
            string memory commonName,
            string memory ipAddress
        )
    {
        // Kiểm tra xem commonName có tồn tại không
        require(commonNameExists[_commonName], "Common Name does not exist");

        VerificationObject memory obj = objects[_commonName];
        return (obj.x509Certificate, obj.commonName, obj.ipAddress);
    }
}