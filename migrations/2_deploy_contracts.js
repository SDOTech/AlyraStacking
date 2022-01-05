var SDO = artifacts.require("./SDOToken.sol");
module.exports = function(deployer) {
  deployer.deploy(SDO,10000);
};
