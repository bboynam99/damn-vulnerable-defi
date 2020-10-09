const { ether, balance } = require('@openzeppelin/test-helpers');
const { accounts, contract } = require('@openzeppelin/test-environment');

const SideEntranceLenderPool = contract.fromArtifact('SideEntranceLenderPool');
const AttackSideEntrance = contract.fromArtifact('AttackSideEntrance');

const { expect } = require('chai');
const { current } = require('@openzeppelin/test-helpers/src/balance');

describe('[Challenge] Side entrance', function () {

    const [deployer, attacker, user, ...otherAccounts] = accounts;

    const ETHER_IN_POOL = ether('1000');

    before(async function () {
        /** SETUP SCENARIO */
        this.pool = await SideEntranceLenderPool.new({ from: deployer });

        await this.pool.deposit({ from: deployer, value: ETHER_IN_POOL });

        this.attackContract = await AttackSideEntrance.new(this.pool.address, { from: attacker });

        this.attackerInitialEthBalance = await balance.current(attacker);

        expect(
            await balance.current(this.pool.address)
        ).to.be.bignumber.equal(ETHER_IN_POOL);
    });

    it('Exploit', async function () {
        await this.attackContract.loan(ether('1000'), { from: attacker });
        await this.attackContract.steal();
    });

    after(async function () {
        /** SUCCESS CONDITIONS */
        expect(
            await balance.current(this.pool.address)
        ).to.be.bignumber.equal('0');

        // Not checking exactly how much is the final balance of the attacker,
        // because it'll depend on how much gas the attacker spends in the attack
        // If there were no gas costs, it would be balance before attack + ETHER_IN_POOL
        expect(
            await balance.current(attacker)
        ).to.be.bignumber.gt(this.attackerInitialEthBalance);
    });
});
