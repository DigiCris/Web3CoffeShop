// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//deployado en mumbai = 0x8409add3ebb0c34F09B97C9AeB2d2074cfE3E488

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Cafe is ERC20 {

    mapping (address => uint256) public nonce;

    constructor() ERC20("cafe", "cf") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
    function decimals() public pure override  returns (uint8) {
        return 0;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, value);
        _transfer(from, to, value);
        return true;
    }


    function getMessageHash( address _to, uint _amount, uint _nonce) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_amount, _to, _nonce));
    }


    function verify(address _to, uint _amount, uint _nonce, bytes memory signature) external returns (address) {
        bytes32 messageHash = getMessageHash( _to, _amount, _nonce);
        address from = recoverSigner(messageHash, signature);
        if(nonce[from]==_nonce){
            nonce[from]++;
            _transfer(from, _to, _amount);
        } else {
            revert("el nonce ya se uso");
        }
        return recoverSigner(messageHash, signature);
    }

    function recoverSigner(bytes32 _ethSignedMessageHash, bytes memory _signature) internal pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        (bytes32 _r, bytes32 _s, uint8 _v) = splitSignature(_signature);
        bytes32 prefixedHashMessage = keccak256(abi.encodePacked(prefix, _ethSignedMessageHash));
        address signer = ecrecover(prefixedHashMessage, _v, _r, _s);
        return signer;
    }

    

    function splitSignature( bytes memory sig ) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(sig.length == 65, "invalid signature length");
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
        return(r,s,v);
    }


}