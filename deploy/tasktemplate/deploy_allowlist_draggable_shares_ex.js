const Confirm = require('prompt-confirm');
const nconf = require('nconf');


module.exports = async function ({ ethers, deployments, getNamedAccounts }) {
  const { deploy } = deployments;

  const { deployer } = await getNamedAccounts();

  const owner = nconf.get("multisigAddress");
  const symbol = nconf.get("symbol");
  const shares = await deployments.get('AllowlistShares'+symbol);
  const recoveryHub = await deployments.get("RecoveryHub");
  const offerFactory = await deployments.get("OfferFactory");
  
  const terms = nconf.get("terms");
  const quorumBps = nconf.get("quorumBps");
  const votePeriodSeconds = nconf.get("votePeriodSeconds");

  if (network.name != "hardhat") {
    console.log("-----------------------")
    console.log("Deploy Allowlist DraggableShares " + symbol)
    console.log("-----------------------")
    console.log("deployer: %s", deployer);
    console.log("shares: %s", shares.address);
    console.log("recoveryHub: %s", recoveryHub.address);
    console.log("offer factory: %s", offerFactory.address);
    console.log("owner: %s", owner); // don't forget to set it in deploy_config.js as the multsigadr
    
    const prompt = await new Confirm("Addresses correct?").run();
    if(!prompt) {
      console.log("exiting");
      process.exit();
    }
  }
  
  const feeData = await ethers.provider.getFeeData();

  const { address } = await deploy("AllowlistDraggableShares"+symbol, {
    contract: "AllowlistDraggableShares",
    from: deployer,
    args: [
      terms,
      shares.address,
      quorumBps,
      votePeriodSeconds,
      recoveryHub.address,
      offerFactory.address,
      owner,
      owner],
    log: true,
    maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
    maxFeePerGas: feeData.maxFeePerGas,
    gasLimit: 3000000
  });
  nconf.set("address.allowlist.draggable");
};

module.exports.tags = ["AllowlistDraggableShares"+nconf.get("symbol")];
module.exports.dependencies = ["RecoveryHub", "OfferFactory", "AllowlistShares"+nconf.get("symbol")];