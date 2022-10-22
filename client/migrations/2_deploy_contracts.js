var Mediations = artifacts.require("MediationOffers.sol");

module.exports = function(deployer) {
  deployer.deploy(Mediations);
};
