import {
    time,
    loadFixture,
  } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import {ethers} from "hardhat";

describe("PiggyFactory", function () {
    async function deployPiggyFactoryFixture() {
        const [owner, account1, account2] = await ethers.getSigners();

        const PiggyFactory = await ethers.getContractFactory("PiggyFactory");
        const piggyFactory = await PiggyFactory.deploy();

        return { piggyFactory, owner };
    }

    describe("Deployment", function () {
        it("Should deploy successfully and set the correct dev address", async function () {
            const { piggyFactory, owner } = await loadFixture(deployPiggyFactoryFixture);

            expect(await piggyFactory.devAddress()).to.equal(owner.address);
        });
    });

    describe("createPiggy", function () {
        it("Should create a new Piggy successfully", async function () {
            const { piggyFactory} = await loadFixture(deployPiggyFactoryFixture);

            await expect(piggyFactory.createPiggy("Mercedes AMG GLE 63 S", 6)).not.to.be.reverted;
        });

        it("Should set the correct owner for the Piggy", async function () {
            const { piggyFactory, owner } = await loadFixture(deployPiggyFactoryFixture);

            const tx = await piggyFactory.createPiggy.staticCall("Mercedes AMG GLE 63 S", 6);


            console.log(tx);
        });
    });
});