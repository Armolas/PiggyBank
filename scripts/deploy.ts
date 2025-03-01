import { ethers } from "hardhat";

async function deployContract() {
    const PiggyFactory = await ethers.getContractFactory("PiggyFactory");

    console.log("Deploying NFT Contract...");

    const deployedContract = await PiggyFactory.deploy();
    await deployedContract.waitForDeployment();

    console.log(`🎉 Contract deployed at: ${deployedContract.target}`);
    return deployedContract;
}

deployContract()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
});

export default deployContract;