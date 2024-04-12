const {network, ethers, deployments} = require("hardhat");

const getConfigPath = () => {
  switch (network.config.chainId) {
    case 1:
      return "/scripts/deploy_config_mainnet.js";
    case 137:
      return "/scripts/deploy_config_polygon.js";
    default:
      return "/scripts/deploy_config_mainnet.js";
  }
}


module.exports = {
  getConfigPath
}