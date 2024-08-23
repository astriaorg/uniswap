// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract CustomizableERC20 is ERC20 {
    uint8 private immutable _DEC;

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _maxSupply) ERC20(_name, _symbol) {
        _DEC = _decimals;
        _mint(msg.sender, _maxSupply);
    }

    function decimals() public view override returns (uint8) {
        return _DEC;
    }
}
