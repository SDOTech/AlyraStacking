const SDOToken = artifacts.require("./SDOToken.sol");
const DAIToken = artifacts.require("./Dai.sol");
const PriceConsumerV3 = artifacts.require("PriceConsumerV3");
const AlyraDaiStaking = artifacts.require("AlyraDaiStaking");

module.exports = async function (deployer,_network,accounts) {

  await deployer.deploy(SDOToken);
  const sdoToken = await SDOToken.deployed();

  await deployer.deploy(DAIToken,10000);
  const daiToken = await DAIToken.deployed();

  await deployer.deploy(PriceConsumerV3);
  const pc = await (PriceConsumerV3.deployed);

  await deployer.deploy(AlyraDaiStaking, sdoToken.address)
  
  console.log('SDOToken:' + SDOToken.address);
  console.log('DAIToken:' + DAIToken.address);
  console.log('PriceConsumerV3:' + PriceConsumerV3.address);
  console.log('AlyraDaiStaking:' + AlyraDaiStaking.address);
  

  
};
