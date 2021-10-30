const main = async () => {
    //compile contract and generate files under artifact directory
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    //create a local Ethereum network for this project via hardhat
    const gameContract = await gameContractFactory.deploy();
    //await for the contract to be mined by the network fake miners
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);
}

const runMain = async () => {
    try {
        await main();
        process.exit(0);
    } catch (error) {
        console.log(error);
        process.exit(1);
    }
};


runMain();