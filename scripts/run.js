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
        [200, 150, 300], //Attack damage values
        "F.R.I.E.N.D.S.",//boss name
        "https://i.imgur.com/ezz7BYS.jpg",//boss imgURI
        10000,//boss ar
        60//boss cp
    );
    //await for the contract to be mined by the network fake miners
    await gameContract.deployed();
    console.log("Contract deployed to:", gameContract.address);

    let txn;

    //mint one NFT with character 2 (hardhat call this with a default wallet)
    txn = await gameContract.mintCharacterNFT(2);
    await txn.wait();

    // //get the value of the NFTs URI
    // let returnedTokenUri = await gameContract.tokenURI(1);
    // console.log("Token URI:", returnedTokenUri);
    txn = await gameContract.attackBoss();
    await txn.wait();

    txn = await gameContract.attackBoss();
    await txn.wait();
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