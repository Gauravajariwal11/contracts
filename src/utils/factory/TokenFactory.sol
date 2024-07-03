// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { AllowlistDraggableFactory } from "./AllowlistDraggableFactory.sol";
import { AllowlistShares, Shares } from "../../shares/AllowlistShares.sol";
import { DraggableTokenFactory } from "./DraggableTokenFactory.sol";
import { FactoryManager } from "./FactoryManager.sol";
import { TokenConfig } from "./FactoryStructs.sol";
import { IERC20Permit } from "../../ERC20/IERC20Permit.sol";
import { Ownable } from "../Ownable.sol";

/**
 * @title Factory to deploy shares contracts
 * @author rube
 * 
 */
contract TokenFactory is Ownable {

  FactoryManager public manager;
  DraggableTokenFactory public draggableFactory;
  AllowlistDraggableFactory public allowlistDraggableFactory;

  event BaseTokenCreated(IERC20Permit indexed token, address indexed owner, bool allowlist);
  event FactoryManagerUpdated(address manager);
  event DraggableTokenFactoryUpdated(DraggableTokenFactory factory);
  event AllowlistDraggableFactoryUpdated(AllowlistDraggableFactory factory);

  error InvalidOwner();

  constructor(address _owner, DraggableTokenFactory _draggableFactory, AllowlistDraggableFactory _allowlistDraggableFactory) Ownable(_owner){
    draggableFactory = _draggableFactory;
    allowlistDraggableFactory = _allowlistDraggableFactory;
  }

  function createToken(TokenConfig calldata tokenConfig, address tokenOwner) public returns (IERC20Permit) {
    if (tokenOwner == address(0))
      revert InvalidOwner();
    IERC20Permit token;
    if (tokenConfig.allowlist) {
      token = new AllowlistShares(tokenConfig.symbol, tokenConfig.name, tokenConfig.terms, tokenConfig.numberOfShares, manager.recoveryHub(), tokenOwner, manager.permit2Hub());
    } else {
      token = new Shares(tokenConfig.symbol, tokenConfig.name, tokenConfig.terms, tokenConfig.numberOfShares, tokenOwner, manager.recoveryHub(), manager.permit2Hub());
    }
    emit BaseTokenCreated(token, tokenOwner, tokenConfig.allowlist);
    if (tokenConfig.draggable) {
      IERC20Permit draggable;
      if (tokenConfig.allowlist) {
        draggable = allowlistDraggableFactory.createAllowlistDraggable(tokenConfig, tokenOwner, token);
      } else {
        draggable = draggableFactory.createDraggable(tokenConfig, tokenOwner, token);
      }
      return draggable;
    } else {
      return token;
    }
  }

  function setManager(FactoryManager _manager) external onlyOwner() {
    manager = _manager;
    emit FactoryManagerUpdated(address(manager));
  }

  function setDraggableTokenFactory(DraggableTokenFactory _draggableFactory) external onlyOwner() {
    draggableFactory = _draggableFactory;
    emit DraggableTokenFactoryUpdated(draggableFactory);
  }

  function setAllowlistDraggableFactory(AllowlistDraggableFactory _allowlistDraggableFactory) external onlyOwner() {
    allowlistDraggableFactory = _allowlistDraggableFactory;
    emit AllowlistDraggableFactoryUpdated(allowlistDraggableFactory);
  }

}