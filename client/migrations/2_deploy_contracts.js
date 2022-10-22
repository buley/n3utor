var Mediations = artifacts.require("Mediations.sol");

module.exports = function(deployer) {
  deployer.deploy(Mediations);
};
