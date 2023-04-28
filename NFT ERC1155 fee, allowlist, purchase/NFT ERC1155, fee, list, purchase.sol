// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract ThisIsNFT is ERC1155, Ownable, Pausable, ERC1155Supply, PaymentSplitter {

    uint256 public publicPrice = 0.02 ether;
    uint256 public allawListPrice= 0.01 ether;
    uint256 public maxSupply = 1;
    uint256 public maxPerWallet = 3;
    
    bool public publicMintOpen = false;
    bool public allowListMintOpen = true;

    mapping (address => bool) allowList;
    mapping (address => uint256) purchasePerWallet;

    constructor(address[] memory _payees, uint256[] memory _shares) ERC1155("") PaymentSplitter(_payees, _shares)
    { }

//create a function to set the allowlist
    function setAllowList (address[] calldata addresses) external onlyOwner{
        for(uint256 i = 0; i < addresses.length; i++){
            allowList[addresses[i]] = true;
        }
    }

// How to manage Mint lists.
    function editMintWindows(bool _publicMintOpen, bool _allowListMintOpen) external onlyOwner {
        publicMintOpen = _publicMintOpen;
        allowListMintOpen = _allowListMintOpen;

    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //Min for people inside AllowList
    function allowListMint(uint256 id, uint256 amount) public payable{
        
        require(allowList[msg.sender], "You are not on the allowlist");
        require(allowListMintOpen, "Allow list mint is closed");
        require(msg.value == allawListPrice * amount);
        mint(id, amount); 

    
    }    

    //Mint for people that are not in allowList
    function publicMint(uint256 id, uint256 amount) public payable{
        
        require(publicMintOpen, "public mint closed");
        require(msg.value == publicPrice * amount, "wrong, not enough money sent"); 
        mint(id, amount); 

    } 

    //Mint function with general conditions
    function  mint(uint256 id, uint256 amount) internal{
        require(purchasePerWallet[msg.sender] + amount <= maxPerWallet, "Too many Nfts" );
        require(id<2, "sorry you are trying to mint the wrong NFT");
        require(totalSupply(id) + amount <= maxSupply, "sorry we have minted out");
        _mint(msg.sender, id, amount, "");
        purchasePerWallet[msg.sender] += amount;
    }  
     // Withdraw function to get the balance inside this contract
    function withdraw(address _addr) external onlyOwner{ 
        uint256 balance = address(this).balance;
        payable(_addr).transfer(balance);

    }
    
    function uri(uint256 _id) public view virtual override onlyOwner returns (string memory) {
        require(exists(_id), "not existent token");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyOwner
    {
        _mintBatch(to, ids, amounts, data);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    

}