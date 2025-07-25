# WineChain

A decentralized wine authenticity verification system for tracking wine quality from vineyard to cellar on Stacks blockchain.

## Features

- Wine bottle registration with vintage and terroir tracking
- Vintner bottle management and quality verification
- Wine sommelier authentication system
- Harvest date and vineyard location tracking
- Comprehensive wine quality monitoring

## Smart Contract Functions

### Public Functions
- `register-wine-sommelier` - Register wine sommelier (supervisor only)
- `register-wine-bottle` - Register new wine bottle
- `verify-wine-quality` - Verify quality (sommelier only)

### Read-Only Functions
- `get-wine` - Get wine details
- `get-vintner-bottles` - Get vintner's bottle list
- `is-wine-sommelier` - Check sommelier status
- `get-total-bottles` - Get total registered bottles
- `get-contract-stats` - Get contract statistics

## Usage

Deploy the contract to create a wine authenticity system where vintners can register their bottles and sommeliers can verify quality throughout the wine supply chain.

## License

MIT