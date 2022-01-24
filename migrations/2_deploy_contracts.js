//const SDOToken = artifacts.require("./SDOToken.sol");
const DAIToken = artifacts.require("./Dai.sol");
const PriceConsumerV3 = artifacts.require("PriceConsumerV3");
const AlyraStaking = artifacts.require("AlyraStaking");

module.exports = async function (deployer,_network,accounts) {

  // await deployer.deploy(SDOToken);
  // const sdoToken = await SDOToken.deployed();

  await deployer.deploy(DAIToken,1000);
  const daiToken = await DAIToken.deployed();

  await deployer.deploy(PriceConsumerV3);
  const pc = await (PriceConsumerV3.deployed);

  //await deployer.deploy(AlyraStaking, sdoToken.address);
  await deployer.deploy(AlyraStaking);
  
  //console.log('SDOToken:' + SDOToken.address);
  console.log('DAIToken:' + DAIToken.address);
  console.log('PriceConsumerV3:' + PriceConsumerV3.address);
  console.log('AlyraStaking:' + AlyraStaking.address);
  
};
