// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// simple contract to test, it allows to save a number in a variable

contract SimpleContract {

    uint public savedNumber;

    // update the savedNumber variable
    function updateNumber(uint _newNumber) public {
        savedNumber = _newNumber;
    }


    // "delete" the number by saving a zero in the savedNumber variable
    function deleteNumber() public {
        savedNumber = 0;
    }

}

// This factory contract allows to:
// - Predict the address of a the SimpleContract contract before deploying it, using the predictAddress function.
// - Deploy the SimpleContract contract using the deploySimpleContract function.

// It uses the salted contract creation method to determine the address of a new contract.
// It predicts a new contract address based on a bytes32 "salt" and an argument that the user will input. 
// https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2 

contract DetermineAddress {

    address public predictedAddress;

    // Takes a bytes32 string as argument to generate the address the SimpleContract contract will be deployed at.
    function predictAddress(bytes32 salt) public {
        predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            address(this),
            salt,
            keccak256(abi.encodePacked(
                type(SimpleContract).creationCode,
                abi.encode()
            ))
        )))));
    }

    // deploy the SimpleContract contract based on the bytes32 salt the user inputs.
    // verify that the contract will be deployed at the address matching the prediction
    function deploySimpleContract(bytes32 salt) public {     
        SimpleContract d = new SimpleContract{salt: salt}();
        require(address(d) == predictedAddress);        
    }
}
