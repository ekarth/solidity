// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

/**
     __ __   ______ ____   __  ___ __  ___ __  __ _   __ ____ ______ ____
  __/ // /_ / ____// __ \\/  |/  //  |/  // / / // | / //  _// ____//  _/
 /_  _  __// /    / / / // /|_/ // /|_/ // / / //  |/ / / / / /_    / /  
/_  _  __// /___ / /_/ // /  / // /  / // /_/ // /|  /_/ / / __/  _/ /   
 /_//_/   \\____/\____//_/  /_//_/  /_/\\____//_/ |_//___//_/    /___/

*/                                                                                

import "./IERC20.sol";

contract CommuniFiFaucet {
    address private owner;
    uint private allowedAmount;
    address private multiSignWalletAddress;

    // Constructor to set the owner and the amount of PLS to send
    constructor(uint _allowedAmount, address _multiSignWalletAddress){
        owner = msg.sender;
        allowedAmount = _allowedAmount * 1e18;
        multiSignWalletAddress = _multiSignWalletAddress;
    }

    // Owner-only modifier
    modifier onlyOwner {
        require(msg.sender == owner, "You are not the owner");
        _;
    }


    // function to send PLS to the address
    function sendPls(address _account) public onlyOwner {
        require(address(this).balance > allowedAmount, "Faucet is running low on assets");
        payable(_account).transfer(allowedAmount);
    }


    // to receive donation for only PLS
    // PLS will be in the faucet to facilitate the users, it will remain in the faucet.
    // Owner has no control over PLS and cannot withdraw it.
    receive() external payable { }


    // function to allow owner to withdraw tokens from the contract
    function withdrawAllTokensByAddress(address _tokenAddress) public onlyOwner {
        uint256 contractBalance = IERC20(_tokenAddress).balanceOf(address(this));
        require(contractBalance > 0, "No tokens to withdraw");
        IERC20(_tokenAddress).transfer(multiSignWalletAddress, contractBalance);
    }


    // returns the allowed amount of PLS to send to an address 
    function getAllowedAmount() public view returns(uint) {
        return allowedAmount;
    }


    // to change the allowed amount 
    function setAllowedAmount(uint _newAllowedAmount) public onlyOwner {
        allowedAmount = _newAllowedAmount * 1e18;
    }

    
    function setMultiSignWalletAddress(address _multiSignWalletAddress) public onlyOwner {
        multiSignWalletAddress = _multiSignWalletAddress;
    }


    function getMultiSignWalletAddress() public view returns(address) {
        return multiSignWalletAddress;
    }


    function transferOwnership(address newOwner) public onlyOwner{
        if(newOwner == address(0)){
            revert("Owner cannot be zero-address");
        }
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal{
        owner = newOwner;
    }


    function renounceOwnership() public onlyOwner{
        _transferOwnership(address(0));
    }
}