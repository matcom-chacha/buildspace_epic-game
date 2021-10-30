// SDPX-License_Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract MyEpicGame {

    //struct to save character properties
    struct CharacterAttributes {
        uint characterIndex;
        string name;
        string imageURI;
        uint ar;//audience rating (HP)
        uint maxAr;//(max HP)
        uint charismaP;//a serial with higer amount of charisma points will decrese with a faster rate the oponents audience(attackDamage)
    }

    //array of default characters
    CharacterAttributes[] defaultCharacters;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        uint[] memory characterAr,
        uint[] memory characterCharismaP
        ) 
        {
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
                console.log("Done initializing %s w/ an audience rating of %s, img %s",c.name, c.ar, c.imageURI);
            }
    }
}