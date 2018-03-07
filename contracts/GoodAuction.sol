pragma solidity 0.4.19;

import "./AuctionInterface.sol";

/** @title GoodAuction */
contract GoodAuction is AuctionInterface {

	/* New data structure, keeps track of refunds owed */
	mapping(address => uint) refunds;

	// Current state of the auction.
	uint public lastBid;
	address public lastBidder;

//	/*  Initialize the auction with a starting bid */
//	function GoodAuction(uint _startingBid) public {
//		highestBid = _startingBid;
//	}

	/* 	Bid function, now shifted to pull paradigm.
		Must return true on successful, send and/or bid, bidder
		reassignment. Must return false on failure and
		allow people to retrieve their funds  */
	function bid() payable external returns(bool) {
		// If the bid is not higher, send the
		// money back.
		if(msg.value <= highestBid) {
			refunds[msg.sender] += msg.value;
			return false;
		}
		// Sending back the money by simply using
		// highestBidder.send(highestBid) is a security risk
		// because it could execute an untrusted contract.
		// It is always safer to let the recipients
		// withdraw their money themselves.
		lastBid = highestBid;
		lastBidder = highestBidder;
		highestBidder = msg.sender;
		highestBid = msg.value;
		refunds[lastBidder] += lastBid;
		return true;
	}

	/*  Implement withdraw function to complete new
	    pull paradigm. Returns true on successful
	    return of owed funds and false on failure
	    or no funds owed.  */
	function withdrawRefund() external returns(bool) {
		// YOUR CODE HERE
		uint amount = refunds[msg.sender];
		if (amount > 0) {
			// It is important to set this to zero because the recipient
			// can call this function again as part of the receiving call
			// before `send` returns.
			refunds[msg.sender] = 0;

			if (!msg.sender.send(amount)) {
				// No need to call throw here, just reset the amount owing
				refunds[msg.sender] = amount;
				return false;
			}
		}
		return true;
	}

	/*  Allow users to check the amount they are owed
		before calling withdrawRefund(). Function returns
		amount owed.  */
	function getMyBalance() constant external returns(uint) {
		return refunds[msg.sender];
	}


	/* 	Consider implementing this modifier
		and applying it to the reduceBid function
		you fill in below. */
	modifier canReduce() {
		if (msg.sender == highestBidder && highestBid - 1 > lastBid)
		_;
	}


	/*  Rewrite reduceBid from BadAuction to fix
		the security vulnerabilities. Should allow the
		current highest bidder only to reduce their bid amount */
	function reduceBid() external canReduce {
		require(highestBidder.send(1)) ;
		highestBid -= 1;

	}


	/* 	Remember this fallback function
		gets invoked if somebody calls a
		function that does not exist in this
		contract. But we're good people so we don't
		want to profit on people's mistakes.
		How do we send people their money back?  */

	function () payable {
		revert();
	}

}
