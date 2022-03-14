// SPDX-License-Identifier: MIT
pragma solidity >=0.8.3;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";

contract DeNeoAlpha is Ownable, ERC721A, ReentrancyGuard {
    string public provenanceHash;
    uint256 public immutable maxMintAllowedPerAddress;
    uint256 public immutable collectionSize;
    uint256 public immutable amountForTeam;

    uint32 public whitelistSaleStartTime;
    uint64 public whitelistPriceWei;
    mapping(address => uint256) whitelistToMaxMintAllowed;

    uint32 public publicSaleStartTime;
    uint64 public publicPriceWei;

    string private _baseTokenURI;

    constructor(
        string memory provenanceHash_,
        uint256 maxMintAllowedPerAddress_,
        uint256 collectionSize_,
        uint256 amountForTeam_
    ) ERC721A("de Neo Alpha", "DNA") {
        provenanceHash = provenanceHash_;
        maxMintAllowedPerAddress = maxMintAllowedPerAddress_;
        collectionSize = collectionSize_;
        amountForTeam = amountForTeam_;
    }

    modifier callerIsUser() {
        require(
            tx.origin == msg.sender,
            "The caller is another smart contract"
        );
        _;
    }

    function refundIfOver(uint256 price) private {
        require(msg.value >= price, "Need to send more ETH");
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }
    }

    function whitelistMint() external payable callerIsUser {
        require(
            block.timestamp >= whitelistSaleStartTime,
            "Whitelist sale has not begun yet"
        );
        require(
            whitelistToMaxMintAllowed[msg.sender] > 0,
            "Not eligible for whitelist"
        );
        require(totalSupply() + 1 <= collectionSize, "Max supply reached");
        whitelistToMaxMintAllowed[msg.sender]--;
        _safeMint(msg.sender, 1);
        refundIfOver(whitelistPriceWei);
    }

    function publicSaleMint(uint256 quantity) external payable callerIsUser {
        require(
            block.timestamp >= publicSaleStartTime,
            "Public sale has not begun yet"
        );
        require(
            totalSupply() + quantity <= collectionSize,
            "Max supply reached"
        );
        require(
            numberMinted(msg.sender) + quantity <= maxMintAllowedPerAddress,
            "Cannot mint this many"
        );
        _safeMint(msg.sender, quantity);
        refundIfOver(publicPriceWei * quantity);
    }

    /// @notice Initial dev mint
    function initialDevMint(uint256 quantity) external onlyOwner {
        require(
            totalSupply() + quantity <= amountForTeam,
            "Too many already minted before dev mint"
        );
        require(
            quantity % maxMintAllowedPerAddress == 0,
            "Can only mint a multiple of the maxBatchSize"
        );
        uint256 numChunks = quantity / maxMintAllowedPerAddress;
        for (uint256 i = 0; i < numChunks; i++) {
            _safeMint(msg.sender, maxMintAllowedPerAddress);
        }
    }

    function addToWhitelist(
        address[] memory addresses,
        uint256[] memory numSlots
    ) external onlyOwner {
        require(
            addresses.length == numSlots.length,
            "Addresses length does not match numSlots length"
        );
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelistToMaxMintAllowed[addresses[i]] = numSlots[i];
        }
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

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
