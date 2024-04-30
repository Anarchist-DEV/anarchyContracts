require("@nomicfoundation/hardhat-toolbox");
require('@openzeppelin/hardhat-upgrades');

// require(" @nomiclabs/hardhat-etherscan")

const { vars } = require("hardhat/config");
const ALCHEMY_API_KEY = vars.get("ALCHEMY_API_KEY");
const MUMBAI_PRIVATE_KEY = vars.get("MUMBAI_PRIVATE_KEY");
const POLYGONSCAN_API_KEY = vars.get("OKLINK_API_KEY");


// @type import('hardhat/config').HardhatUserConfig 
module.exports = {
  solidity: "0.8.24",
  networks: {
    amoy: {
      url: `https://polygon-amoy.g.alchemy.com/v2/_cB_1CbH4t54GQNHFCLlRy1hqBLe_dAO`,
      accounts: [MUMBAI_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      amoy: POLYGONSCAN_API_KEY,
  },
  customChains: [
    {
      network: "amoy",
      chainId: 80002,
      urls: {
        apiURL: "https://www.oklink.com/api/explorer/v1/contract/verify/async/api/polygonAmoy",

        browserURL: "https://www.oklink.com/polygonAmoy"
      }
    }
  ]
},

};
