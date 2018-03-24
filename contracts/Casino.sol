pragma solidity ^0.4.20;

/**
 * Casino contract
 * Author:: Varun Barala
 */
contract Casino {
	address public owner;
	address[] public players;
	
	// default uint is 256 bit
	uint totalBets;
	uint minBet;
	uint numberOfBets;

	// store player infor against address
	mapping (address => Player) public playerInfo;
	

	// player info
	struct Player {
		uint amountBet;
		uint numberSelected;
	}

	function Casino(uint _minBet) public {
		owner = msg.sender;
		// no need to check for negative (uint)
		if(_minBet != 0) minBet = _minBet;
	}

	function checkPlayerExist(address player) public constant returns(bool) {
		for(uint i=0; i< players.length; i++){
			if (players[i] == player) return true;
		}
		return false;
	}

	//player can only select from [1,10]
	function bet(uint numberSelected) public payable {
		//perform basic checks on caller
		require (!checkPlayerExist(msg.sender));
		require (numberSelected >=1 && numberSelected <=10);
		require (msg.value >= minBet);
		
		playerInfo[msg.sender].amountBet = msg.value;
		playerInfo[msg.sender].numberSelected = numberSelected;

		players.push(msg.sender);
		numberOfBets++;
		totalBets+=msg.value;
	}

	function resetVars() internal {
		totalBets = 0;
		numberOfBets = 0;
	}

	function distributePrizes (uint winningNumber) public {
		// in memory winners list, needed to decide the prize eth
		address[numberOfBets] memory winners;
		uint count = 0;

		for(uint i=0; i<players.length; i++) {
			address playerAddress = players[i];
			if (playerInfo[playerAddress].numberSelected == winningNumber) {
				winners[count] = playerAddress;
				count++;
			}
			delete playerInfo[playerAddress];
		}

		playerInfo.length = 0; //delete all the info

		//decide prize eth for each winner
		uint prizeMoney = totalBets/count;

		for(uint k=0; k<count; k++) {
			if (winners[k] != address(0)) {
				winners[k].transfer(prizeMoney);
			}
		}

		resetVars();
	}
	
	//generate a number from [1,10] which will decide the winners
	function generateRandomNumber() public {
		/*
		* This is not secure:-
		* block number is public info
		* one block has min 12 second life cycle
		*/

		uint generateRandomNumber = block.number % 10 + 1; 
		distributePrizes(generateRandomNumber);
	}

	function kill() public {
		if(msg.sender == owner) selfdestruct(owner);
	}
}