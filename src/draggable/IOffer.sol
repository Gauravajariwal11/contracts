// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../ERC20/IERC20.sol";

interface IOffer {

	/*//////////////////////////////////////////////////////////////
                            Custom errors
  //////////////////////////////////////////////////////////////*/
	/// Invalid msg.sender.
	/// @param sender The msg.sender of the transaction.
	error Offer_InvalidSender(address sender);
	/// Offer needs to be still open.
	error Offer_AlreadyAccepted();
	/// Offer needs to be not accepted yet.
	error Offer_NotAccepted();
	/// Sender of the offer needs to have needed funds in his account.
	error Offer_NotWellFunded();
	/// New offer needs to be with a better price than the old offer.
	/// @param oldPrice Price of the old offer.
	/// @param newPrice Price of the new offer.
	error Offer_OldOfferBetter(uint256 oldPrice, uint256 newPrice);
	/// Voting needs to be still open.
	error Offer_VotingEnded();
	/// (External) Reported votes needs to not exceed total votes.
	/// @param maxVotes The max possible votes for the token.
	/// @param reportedVotes The external reported votes + circulating supply of the token.
	error Offer_TooManyVotes(uint256 maxVotes, uint256 reportedVotes);

	function makeCompetingOffer(IOffer newOffer) external;

	// if there is a token transfer while an offer is open, the votes get transfered too
	function notifyMoved(address from, address to, uint256 value) external;

	function currency() external view returns (IERC20);

	function price() external view returns (uint256);

	function isWellFunded() external view returns (bool);

	function voteYes() external;

	function voteNo() external;
}