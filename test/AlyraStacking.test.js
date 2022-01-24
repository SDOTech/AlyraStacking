
const DaiToken = artifacts.require("./DaiToken.sol");
//const SDOToken = artifacts.require("./SDOToken.sol");
const AlyraStacking = artifacts.require('./AlyraStaking.sol');
const { assert,expect } = require('chai');
const truffleAssert = require('truffle-assertions');
const { inTransaction } = require('@openzeppelin/test-helpers/src/expectEvent');
const { BN, ether, time } = require('@openzeppelin/test-helpers');




contract("AlyraStacking", accounts => {

    const _DaiName = 'Dai';
    //const _SDOName = 'SDO Coin';
    
    const _initialDaisupply = new BN(1000);
    const _decimals = new BN(0);
    const owner = accounts[0];
    const spender = accounts[5];
    const _initialAmountOfStake = 10;
    const _initialAmountToWithdraw = 1;
    
    beforeEach(async function () {
        DaiInstance = await DaiToken.new(_initialDaisupply, { from: owner });
        //SDOInstance = await SDOToken.new({ from: owner });
        //AlyraStackingInstance = await AlyraStacking.new(SDOInstance.address, { from: owner }); 
        AlyraStackingInstance = await AlyraStacking.new({ from: owner }); 
        
        await DaiInstance.approve(AlyraStackingInstance.address, 500, { from: spender })
    });

    it('Test sur les noms', async function () {
        expect(await DaiInstance.name()).to.equal(_DaiName);
        //expect(await SDOInstance.name()).to.equal(_SDOName);
    });

    it('Check Dai totalSupply', async function () {
        
        let totalSupply = await DaiInstance.totalSupply();        
        //console.log('totalSupply: '+totalSupply);
        expect(totalSupply).to.be.bignumber.equal(_initialDaisupply);
    });
    
    it("amount staked should be stored [stakeToken - getUserBalance]", async () => {  
        
        //give dai to spender
        await DaiInstance.transfer(spender, _initialAmountOfStake, { from: owner });

        // let balSpender = await DaiInstance.balanceOf(spender);
        // let daiContractBal = await DaiInstance.balanceOf(owner);
        // console.log('balSpender: ' + balSpender);
        // console.log('daiContractBal: '+ daiContractBal);
    
        //spender stake _initialAmountOfStake DAI on contract        
        const tx = await AlyraStackingInstance.stakeToken(DaiInstance.address, _initialAmountOfStake, { from: spender });  
        truffleAssert.eventEmitted(tx, 'TokenStaked'); //test if event is fired
        
        let amountForSpender = await AlyraStackingInstance.getUserBalance(spender, DaiInstance.address);
        //console.log('amountForSpender: ' + amountForSpender);
        assert(amountForSpender, _initialAmountOfStake); //test amount is correctly stacked
    });

    it("withdraw a specific amount [withdrawTokens]", async () => {        

        //give dai to spender
        await DaiInstance.transfer(spender, _initialAmountOfStake, { from: owner });
        
        //stake
        await AlyraStackingInstance.stakeToken(DaiInstance.address, _initialAmountOfStake, { from: spender }); 
        
        let amountForSpenderBeforeWithdraw = await AlyraStackingInstance.getUserBalance(spender, DaiInstance.address);

        const tx = await AlyraStackingInstance.withdrawTokens(DaiInstance.address, _initialAmountToWithdraw, { from: spender });
        truffleAssert.eventEmitted(tx, 'TokenWithdrawn'); //test if event is fired

        let amountForSpenderAfterWithdraw = await AlyraStackingInstance.getUserBalance(spender, DaiInstance.address);         
        expect(parseInt(amountForSpenderBeforeWithdraw)).to.be.greaterThan(parseInt(amountForSpenderAfterWithdraw));
        
    });

    it("compute rewards should be ok", async () => { 

        //give dai to spender
        await DaiInstance.transfer(spender, _initialAmountOfStake, { from: owner });
        
        //stake
        await AlyraStackingInstance.stakeToken(DaiInstance.address, _initialAmountOfStake, { from: spender }); 

        //let reward = await AlyraStackingInstance.computeReward(spender, DaiInstance.address);
        let reward = await AlyraStackingInstance.computeReward.call(spender, DaiInstance.address);
        console.log(`reward before: ${reward}`);

        // add 2 days 
        await time.increase(time.duration.days(3));

        let rewardAfter = await AlyraStackingInstance.computeReward.call(spender, DaiInstance.address);
        console.log(`reward after: ${rewardAfter}`);

    });

});