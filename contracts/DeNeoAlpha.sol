// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";

contract DeNeoAlpha is Ownable, ERC721A, ReentrancyGuard {
    uint256 public immutable maxMintAmountPerAddress;
    uint256 public immutable amountForTeam;
    uint256 public immutable amountForPublicAndTeam;
    string private _baseTokenURI;
    uint32 public publicSaleStartTime;
    uint64 public whitelistPriceWei;
    uint64 public publicPriceWei;
    mapping(address => uint256) whitelist;

    constructor(
        uint256 maxMintAmountPerAddress_,
        uint256 collectionSize_,
        uint256 amountForTeam_
    )
        ERC721A(
            "de Neo Alpha",
            "DNA",
            maxMintAmountPerAddress_,
            collectionSize_
        )
    {
        maxMintAmountPerAddress = maxMintAmountPerAddress_;
        amountForPublicAndTeam = amountForPublicAndTeam;
        amountForTeam = amountForTeam_;
    }

    modifier callerIsUser() {
        require(
            tx.origin == msg.sender,
            "The caller is another smart contract"
        );
        _;
    }

    function whitelistMint() external payable callerIsUser {
        require(whitelistPriceWei != 0, "Mintlist sale has not begun yet");
        require(whitelist[msg.sender] > 0, "Not eligible for whitelist");
        require(totalSupply() + 1 <= collectionSize, "Max supply reached");
        whitelist[msg.sender]--;
        _safeMint(msg.sender, 1);
        refundIfOver(whitelistPriceWei);
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function publicSaleMint(uint256 quantity) external payable callerIsUser {}

    function isPublicSaleOn(uint256 publicPriceWei) {}

    function setBaseURI(string calldata baseURI) external onlyOwner {
        _baseTokenURI = baseURI;
    }

    function withdrawMoney() external onlyOwner nonReentrant {
        (bool success, ) = msg.sender.call{value: address(this).balance}("");
        require(success, "Transfer failed");
    }

    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }

    function getOwnershipData(uint256 tokenId)
        external
        view
        returns (TokenOwnership memory)
    {
        return ownershipOf(tokenId);
    }
}
