const Confirm = require('prompt-confirm');
const nconf = require('nconf');
const { getConfigPath } = require('../scripts/utils.js');
const config = require(`..${getConfigPath()}`);

module.exports = async function ({ ethers, deployments, getNamedAccounts, network }) {
  const { deploy } = deployments;

  const { deployer, owner } = await getNamedAccounts();

  let brokerbotRegistry
  if (network.name != "hardhat") {
    brokerbotRegistry = config.brokerbotRegistry; //for production deployment
  } else {
    const brokerbotRegistryContract = await deployments.get('BrokerbotRegistry'); // for testing
    brokerbotRegistry = brokerbotRegistryContract.address;
  }
    
  if (network.name != "hardhat" && !nconf.get("silent")) {
    console.log("-----------------------")
    console.log("Deploy Brokerbot Router")
    console.log("-----------------------")
    console.log("deployer: %s", deployer);
    console.log("registry: %s", brokerbotRegistry);

    const prompt = await new Confirm("Addresses correct?").run();
    if(!prompt) {
      console.log("exiting");
      process.exit();
    }
  }

  const feeData = await ethers.provider.getFeeData();

  const { address } = await deploy("BrokerbotRouter", {
    contract: "BrokerbotRouter",
    from: deployer,
    args: [
      brokerbotRegistry],
    log: true,
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
    maxFeePerGas: feeData.maxFeePerGas
  });
};

module.exports.tags = ["BrokerbotRouter"];