# Intro

This script is a community effort to facilitate the creation of AVAX Nodes on Everest Release.

This script automates the steps of the following guide https://medium.com/avalabs/how-to-join-avalanche-everest-release-a40cd20aa654

Check our previous script for DENALI TESTNET on:
https://medium.com/@ablock.io/guide-launch-your-denali-node-with-aws-from-a-to-z-4a13ebac1466


## Usage

  1. Connect to your VPS
  2. launch the following command
```shell
curl -s https://raw.githubusercontent.com/ablockio/Auto-AVAX-Everest-node-deployment/master/install_avax_everest_node.sh | bash
```
  3. Once done, go to the cloned repository
  4. Update config.json file with your username and password (or keep it as it is as we are still on testnet)
  5. launch nodejs installation script
```shell
node launch_node.js
```
  6. When you are asked to go to the faucet https://faucet.avax.network/, copy your X-Chain address to the faucet to credit 10 000 000 nAVA tokens
  7. Enjoy :)


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[MIT](https://choosealicense.com/licenses/mit/)
