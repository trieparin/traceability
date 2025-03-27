import '@nomicfoundation/hardhat-toolbox';
import { HardhatUserConfig } from 'hardhat/config';

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.29',
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
};

export default config;
