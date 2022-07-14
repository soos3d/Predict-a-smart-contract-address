# Predict a smart contract address before it's deployed.

This repository explains how the CREATE2 functionality in Solidity can be used to predict the address where a smart contract will be deployed at.

This example is taken from the Solidity docs describing [salted contract creation](https://docs.soliditylang.org/en/latest/control-structures.html#salted-contract-creations-create2).

## How is a smart contract address generated

### Traditional way 

When creating a contract, the address of the contract is computed from the address creating the contract and a counter that is increased with each contract creation, more known as ```nonce```.

### Salted contract creation

If you specify the option salt, which in this case is a [bytes32](https://jeancvllr.medium.com/solidity-tutorial-all-about-bytes-9d88fdb22676#:~:text=The%20fixed%20length%20bytes32%20can,not%20support%20variable%20length%20type.) value, then the contract creation process will use a different mechanism to come up with the address of the new contract.

It will compute the address from:

- The address of the creating contract.
- The given salt value.
- The (creation) bytecode of the created contract.
- The constructor arguments (if any).

This can be useful if for example, you need to destroy a contract and then re-deploy an updated version at the same address.

## The code

This smart contract is composed by two contracts:

- SimpleContract
- DetermineAddress

### SimpleContract code

The first contract is named ```SimpleContract``` and is the contract that we use as an example. It is a basic smart contract that simply allows you to save a number into a variable.

```sol

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
```

This is the contract that we will predict the address of and deploy. 

### DetermineAddress code

This contract holds the functions to predict the new address, and deploy the new smart contract.

It has one variable named ```predictedAddress```.

```sol
address public predictedAddress;
```

This variable will store the new smart contract address that is predicted before deployng the contract. 

The ```predictAddress``` function is what computes the address of the new contract before deploying. This is just a slight variation of the code you find in the Solidity docs. 

You can use this website to [convert a regular string into bytes32](https://web3-type-converter.onbrn.com/). 

```sol
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
```

This function takes a ```bytes32``` string as a parameter ans uses it as a "[salt](https://en.wikipedia.org/wiki/Salt_(cryptography))" to compute the new contract address. 

It then saves the address computed into the ```predictedAddress``` variable, which is public and can be seen by anyone. 

>**Note** You could just stop here if all you need is to predict the address!

Then the ```deploySimpleContract``` function is used to deploy the contract. It also takes a ```bytes32``` parameter and note that the ```require``` statement checks that the address predicted matches the address of the contract being deployed. The transaction will be reverted if they don't match. 

```sol
function deploySimpleContract(bytes32 salt) public {     
    SimpleContract d = new SimpleContract{salt: salt}();
    require(address(d) == predictedAddress);        
}
```

## Deploy and test this smart contract
