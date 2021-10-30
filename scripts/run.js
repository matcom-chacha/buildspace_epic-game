const main = async () => {
    //compile contract and generate files under artifact directory
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    //create a local Ethereum network for this project via hardhat
    const gameContract = await gameContractFactory.deploy(
        ["Modern Family", "HIMYM", "Brooklyng 99"], //Names
        ["https://i.imgur.com/pKd5Sdk.png", // Images
            "https://i.imgur.com/xVu4vFL.png",
            "https://i.imgur.com/WMB6g9u.png"],
        [500, 400, 300], //HP values
        [200, 150, 300] //Attack damage values
    );
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