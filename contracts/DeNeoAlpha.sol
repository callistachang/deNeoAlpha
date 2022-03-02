// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "erc721a/contracts/ERC721A.sol";

contract DeNeoAlpha is ERC721A {
    constructor() ERC721A("de Neo Alpha", "DNA") {}

    function mint(uint256 quantity) external payable {
        // _safeMint's second argument now takes in a quantity, not a tokenId.
        _safeMint(msg.sender, quantity);
    }
}
