const Dai = artifacts.require("./Dai.sol");
const AlyraStacking = artifacts.require('./AlyraStaking.sol');
const { assert } = require('chai');
const truffleAssert = require('truffle-assertions');


contract("AlyraStacking", accounts => {

    const userAccount = accounts[1];  

    before(async function () {

        //this.contractInstance = await AlyraStacking.new({from: owner});
    });

    
    it("user stake should be stored", async () => { 

        const AlyraStackingInstance = await AlyraStacking.deployed();
        const daiInstance = await Dai.deployed();
        
        // give 1000 dai to user
        await daiInstance.faucet(userAccount, 1000);

        //user stake 10 dai on contract        
        const balance1 = await AlyraStackingInstance.stakeToken(daiInstance.address, 10);         
        assert.equal(AlyraStackingInstance.stakingUserBalance[userAccount][daiInstance.address].stakedAmount, 10);

    });

});