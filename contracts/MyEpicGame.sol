// SDPX-License_Identifier: UNLICENSED

pragma solidity ^0.8.0;

//NFT contract to inherit from
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//helper functions OpenZeppelin provides
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

//helper to encode in bas64
import "./libraries/Base64.sol";

import "hardhat/console.sol";

contract MyEpicGame is ERC721{

    //struct to save character properties
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint ar;//audience rating (HP)
        uint maxAr;//(max HP)
        uint charismaP;//a serial with higer amount of charisma points will decrese with a faster rate the oponents audience(attackDamage)
    }

    struct BigBoss {
        string name;
        string imageURI;
        uint ar;
        uint maxAr;
        uint charismaP;
    }

    BigBoss public bigBoss;

    // for NFTs id
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    //array of default characters
    CharacterAttributes[] defaultCharacters;

    //to access NFT characte attributes by his tokenId
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    //to store the link bt NFT - owner
    mapping(address => uint256) public nftHolders;

    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(uint newBossAr, uint newPlayerAr);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterAr,
        uint[] memory characterCharismaP,
        string memory bossName,
        string memory bossImageURI,
        uint bossAr,
        uint bossCharismaP
        ) 
        ERC721("AwesomeSeries", "AS")
        {
            //initialize characters
            bigBoss = BigBoss({
                name: bossName,
                imageURI: bossImageURI,
                ar: bossAr,
                maxAr: bossAr,
                charismaP: bossCharismaP
            });

            console.log("Done initializing boss %s w/ %s ar, img %s", bigBoss.name, bigBoss.ar, bigBoss.imageURI);

            //initialize characters
            for( uint i = 0; i < characterNames.length; i+=1){
                defaultCharacters.push(CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    ar: characterAr[i],
                    maxAr: characterAr[i],
                    charismaP: characterCharismaP[i]
                }));

                CharacterAttributes memory c = defaultCharacters[i];
                
                // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
                console.log("Done initializing %s w/ an audience rating of %s, img %s",c.name, c.ar, c.imageURI);
            }

            //Increment token Id so first token will have id 1
            _tokenIds.increment();
    }

    function mintCharacterNFT(uint _characterIndex) external {
        //get current tokenId
        uint256 newItemId = _tokenIds.current();

        //assing tokenId to the caller's wallet address
        _safeMint(msg.sender, newItemId);

        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            ar: defaultCharacters[_characterIndex].ar,
            maxAr: defaultCharacters[_characterIndex].ar,
            charismaP: defaultCharacters[_characterIndex].charismaP
        });

        console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);

        //register token owner
        nftHolders[msg.sender] = newItemId;

        //every user most use a different tokenID
        _tokenIds.increment();

        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex);
    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

        string memory strAr = Strings.toString(charAttributes.ar);
        string memory strMaxAr = Strings.toString(charAttributes.maxAr);
        string memory strCharismaP = Strings.toString(charAttributes.charismaP);

        string memory json = Base64.encode(
            bytes(
            string(
                abi.encodePacked(
                '{"name": "',
                charAttributes.name,
                ' -- NFT #: ',
                Strings.toString(_tokenId),
                '", "description": "This is an NFT that lets people play in the game Metaverse Series!", "image": "',
                charAttributes.imageURI,
                '", "attributes": [ { "trait_type": "Audience Rating", "value": ',strAr,', "max_value":',strMaxAr,'}, { "trait_type": "Charisma Points", "value": ',
                strCharismaP,'} ]}'
                )
            )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function attackBoss() public {
        // Get the state of the player's NFT.
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
        console.log("\nPlayer w/ character %s is about to attack. Has %s ar and %s cp", player.name, player.ar, player.charismaP);
        console.log("Boss %s has %s ar and %s cp", bigBoss.name, bigBoss.ar, bigBoss.charismaP);

        // Make sure the player has more than 0 HP.
        require(player.ar > 0, "Error: character must have ar to attack boss");

        // Make sure the boss has more than 0 HP.
        require(bigBoss.ar >0, "Error: boss must have ar to be attacked");
        
        // Allow player to attack boss.
        if(bigBoss.ar < player.charismaP) {
            bigBoss.ar = 0;
        }else {
            bigBoss.ar = bigBoss.ar - player.charismaP;
        }

        console.log("Player atacked Boss. New boss ar: %s", bigBoss.ar);

        // Allow boss to attack player.
        if(player.ar < bigBoss.charismaP){
            player.ar = 0;
        } else {
            player.ar = player.ar - bigBoss.charismaP;
        }

        console.log("Boss atacked player. New player ar: %s\n", player.ar);
        emit AttackComplete(bigBoss.ar, player.ar);
    }

    function checkIfUserHasNft() public view returns (CharacterAttributes memory) {
        // Get the tokenId of the user's character NFT
        uint256 userNftTokenId = nftHolders[msg.sender];
        
        // If the user has a tokenId in the map, return their character.
        if(userNftTokenId > 0) {//taking advantage of default value of 0 in non set slots
            return nftHolderAttributes[userNftTokenId];
        }

        // Else, return an empty character.
        else {
            CharacterAttributes memory emptyStruct;
            return emptyStruct;
        }
    }

    function getAllDefaultCharacters() public view returns(CharacterAttributes[] memory){
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory){
        return bigBoss;
    }
}