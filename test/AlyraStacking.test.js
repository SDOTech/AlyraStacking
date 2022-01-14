const Dai = artifacts.require("./Dai.sol");
const AlyraStacking = artifacts.require('./AlyraStaking.sol');
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');

contract("AlyraStacking", accounts => {

    const userAccount = accounts[1];   

    it("user stake should be stored", async () => { 

        const AlyraStackingInstance = await AlyraStacking.deployed();
        const daiInstance = await Dai.deployed();

        
        // give 1000 dai to user
        await daiInstance.faucet(userAccount, 1000);

        //user stake 10 dai on contract        
        const balance1 = await AlyraStackingInstance.stakeToken.call(daiInstance.address, 10);
        const balance2 = await AlyraStackingInstance.getUserBalance.call(userAccount, daiInstance.address);
                
        console.log("==> balance return after stakeToken:" + balance1);
        console.log("==> balance returned with getUserBalance:" + balance2);
        
        
        //assert.equal(AlyraStackingInstance.stakingUserBalance[userAccount][daiInstance.address].stakedAmount, 10);

    });

});