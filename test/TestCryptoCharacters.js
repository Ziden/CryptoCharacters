const { expect } = require('chai');
const { assert } = require('console');
const { BigNumber } = require('ethers');
const { ethers } = require('hardhat');

const OWNER_ADDRESS = ethers.utils.getAddress("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");

describe('CryptoCharacters', function () {
    before(async function () {
        this.Chars = await ethers.getContractFactory("CryptoCharacters");
    });

    beforeEach(async function () {
        this._chars = await this.Chars.deploy()
        this._chars = await this._chars.deployed()
        this.provider = ethers.getDefaultProvider();
    });

    it('test incrementing tokens', function () {
        this._chars.getFreeItem.call(OWNER_ADDRESS, OWNER_ADDRESS);
        this._chars.getFreeItem.call(OWNER_ADDRESS, OWNER_ADDRESS);
        this._chars.getFreeItem.call(OWNER_ADDRESS, OWNER_ADDRESS);
        this._chars.getCurrentTokenID().then(result => {
            expect(result).to.equal(4);
        });
    });

    it('test bidding', async function () {
        var provider = this.provider;

        var balancePrev = await this._chars.getBalance();
        balancePrev = balancePrev.toNumber();

        var bidAmount = 100;
        var tokenID = 1;
        this._chars.bid.call(OWNER_ADDRESS, tokenID, {value: bidAmount});

        var balanceAfter = await this._chars.getBalance();
        balanceAfter = balanceAfter.toNumber();
        
        expect(this._chars.currentBid).to.equal(undefined);
        expect(balanceAfter).to.equals(balancePrev + bidAmount);
    });

});