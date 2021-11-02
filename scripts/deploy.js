//file to deploy to an actuall ethereum network(or a fake one initialy to test)
const main = async () => {
    //compile contract and generate files under artifact directory
    const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
    //create a local Ethereum network for this project via hardhat
    const gameContract = await gameContractFactory.deploy(
        ["Modern Family", "HIMYM", "Brooklyng 99"], //Names
        ["https://i.imgur.com/xLFfRnW.jpg", // Images
            "https://i.imgur.com/Y0eT9F0.jpg",
            "https://i.imgur.com/zCVAbeI.jpg"],
        [500, 400, 300], //HP values
        [200, 150, 300] //Attack damage values
    );
    //await for the contract to be mined by the network fake miners
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;
    //mint one NFT with character 2 (hardhat call this with a default wallet)
    txn = await gameContract.mintCharacterNFT(0);
    await txn.wait();
    console.log("Minted character NFT #1")


    //mint one NFT with character 2 (hardhat call this with a default wallet)
    txn = await gameContract.mintCharacterNFT(1);
    await txn.wait();
    console.log("Minted character NFT #2")

    //mint one NFT with character 2 (hardhat call this with a default wallet)
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();
    console.log("Minted character NFT #3")

    console.log("Done deploying and minting");
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