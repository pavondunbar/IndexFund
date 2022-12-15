//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract IndexFund {

    mapping(address => uint) public balances;

    constructor() {
        calculatePricePerToken();
    }    

    function balanceOf(address user) external view returns(uint) {
        return balances[user]; 
    }

    function getBalance() external view returns(uint) {
        return address(this).balance;
    }
    
    receive() external payable {}

    // Testing on the Ethereum Mainnet for ERC20-ETH pairs using Chainlink Oracles at https://docs.chain.link/data-feeds/price-feeds/addresses
    AggregatorV3Interface public oceanPriceAggregator = AggregatorV3Interface(0x9b0FC4bb9981e5333689d69BdBF66351B9861E62);
    AggregatorV3Interface public sushiPriceAggregator = AggregatorV3Interface(0xe572CeF69f43c2E488b33924AF04BDacE19079cf);
    AggregatorV3Interface public ohmPriceAggregator = AggregatorV3Interface(0x90c2098473852E2F07678Fe1B6d595b1bd9b16Ed);
    AggregatorV3Interface public amplPriceAggregator = AggregatorV3Interface(0x492575FDD11a0fCf2C6C719867890a7648d526eB);
    AggregatorV3Interface public batPriceAggregator = AggregatorV3Interface(0x0d16d4528239e9ee52fa531af613AcdB23D88c94);

    int public oceanPrice;
    int public sushiPrice;
    int public ohmPrice;
    int public amplPrice;
    int public batPrice;

    function getPricesOfAllCoins() public {

        (,int oceanPrice1,,,) = oceanPriceAggregator.latestRoundData();
        (,int sushiPrice1,,,) = sushiPriceAggregator.latestRoundData();
        (,int ohmPrice1,,,) = ohmPriceAggregator.latestRoundData();
        (,int amplPrice1,,,) = amplPriceAggregator.latestRoundData();
        (,int batPrice1,,,) = batPriceAggregator.latestRoundData();

        oceanPrice = oceanPrice1;
        sushiPrice = sushiPrice1;
        ohmPrice = ohmPrice1;
        amplPrice = amplPrice1;
        batPrice = batPrice1;

    }

    uint public pricePerToken;

    function calculatePricePerToken() public {
        getPricesOfAllCoins();
        pricePerToken = uint(
            oceanPrice * 100 + 
            sushiPrice * 100 + 
            ohmPrice * 100 +
            amplPrice * 100 +
            batPrice * 100 
        );
    }

    function buyToken(uint amount) public payable {
        require(msg.value >= amount * pricePerToken, "insufficient funds");
        balances[msg.sender] += amount;
    }

    //function defiIncreased() public {
    //    pricePerToken = pricePerToken * 2;
    //}

    function redeemToken() public {
        uint amountOfTokens = balances[msg.sender];
        uint amountInWeiToTransfer = amountOfTokens * pricePerToken;
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(amountInWeiToTransfer);
    }
}

