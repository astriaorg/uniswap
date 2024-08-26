// SPDX-License-Identifier: MIT
pragma solidity =0.7.6;

import { Script, console, stdJson } from "forge-std/Script.sol";

contract DeployScript is Script {
    using stdJson for string;

    string internal json = "deploy";
    string internal finalJson = "{}";
    string internal deployPath = vm.envString("DEPLOY_JSON");

    function start() internal {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        require(privateKey != 0, "PRIVATE_KEY environment variable is not set or invalid");
        vm.startBroadcast(privateKey);

        if (vm.isFile(deployPath)) {
            finalJson = vm.readFile(deployPath);
            vm.serializeJson(json, finalJson);
        }
    }

    function end() internal {
        vm.stopBroadcast();
    }

    function getAddress(string memory key) internal view returns (address) {
        string memory path = string(abi.encodePacked(".", key));
        if (vm.keyExistsJson(finalJson, path)) {
            return finalJson.readAddress(path);
        }
        return address(0);
    }

    function setAddress(string memory key, address value) internal {
        finalJson = json.serialize(key, value);
        finalJson.write(deployPath);
    }

    function asciiStringToBytes32(string memory _str) internal pure returns (bytes32) {
        require(bytes(_str).length <= 32, "String must be 32 bytes or less");
        bytes32 result;
        assembly {
            result := mload(add(_str, 32))
        }
        return result;
    }
}
