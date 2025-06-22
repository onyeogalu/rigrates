# Rigrates

**Cross-chain Bitcoin derivatives tracking mining difficulty as synthetic exposure**

Rigrates is a decentralized derivatives platform built on Stacks that enables users to gain synthetic exposure to Bitcoin network metrics without directly holding Bitcoin. The protocol tracks Bitcoin mining difficulty as the underlying asset, allowing traders to speculate on Bitcoin network health and mining economics.

## 🚀 Features

- **Synthetic Bitcoin Exposure**: Trade Bitcoin network metrics without holding BTC
- **Long/Short Positions**: Bet on mining difficulty increases or decreases
- **Oracle-Driven Pricing**: Reliable difficulty data from authorized oracles
- **Cross-Chain Architecture**: Built on Stacks for Bitcoin-native functionality
- **Risk Management**: Automated liquidation and position management
- **Decentralized Governance**: Community-controlled oracle authorization

## 📊 How It Works

### Mining Difficulty Derivatives

The protocol creates synthetic instruments that track Bitcoin mining difficulty:

- **Long Positions**: Profit when mining difficulty increases (bullish on Bitcoin adoption/price)
- **Short Positions**: Profit when mining difficulty decreases (bearish on mining economics)
- **Automatic Settlement**: Positions are settled based on real difficulty changes

### Oracle System

Authorized oracles provide real-time Bitcoin network data:
- Mining difficulty updates from Bitcoin blockchain
- Burn block height tracking for precise timing
- Multi-oracle architecture for redundancy and reliability

## 🛠 Technical Architecture

### Smart Contract Components

```
Rigrates
├── Position Management
│   ├── open-long-position
│   ├── open-short-position
│   └── close-position
├── Oracle System
│   ├── update-difficulty
│   ├── add-oracle
│   └── remove-oracle
├── Risk Management
│   ├── liquidate-position
│   ├── pause-contract
│   └── calculate-pnl
└── Data Storage
    ├── user-positions
    ├── difficulty-oracle
    └── authorized-oracles
```

### Key Data Structures

**User Positions**
```clarity
{
  long-amount: uint,
  short-amount: uint,
  entry-difficulty: uint,
  entry-height: uint,
  settled: bool
}
```

**Oracle Data**
```clarity
{
  difficulty: uint,
  timestamp: uint,
  oracle: principal
}
```

## 🔧 Installation & Deployment

### Prerequisites

- Clarinet CLI
- Stacks Blockchain access
- Node.js (for testing)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/onyeogalu/rigrates.git
cd rigrates
```

2. Install dependencies:
```bash
clarinet install
```

3. Run tests:
```bash
clarinet test
```

4. Deploy to testnet:
```bash
clarinet deploy --network testnet
```

## 📈 Usage Examples

### Opening a Long Position

Bet that Bitcoin mining difficulty will increase:

```clarity
;; Open long position for 1000 units
(contract-call? .hashflow-protocol open-long-position u1000)
```

### Opening a Short Position

Bet that Bitcoin mining difficulty will decrease:

```clarity
;; Open short position for 500 units
(contract-call? .hashflow-protocol open-short-position u500)
```

### Checking Position PnL

View current profit/loss:

```clarity
;; Get PnL for current user
(contract-call? .hashflow-protocol calculate-pnl tx-sender)
```

### Closing Position

Settle and realize gains/losses:

```clarity
;; Close position and settle PnL
(contract-call? .hashflow-protocol close-position)
```

## 🔮 Oracle Integration

### Becoming an Oracle

1. Contact protocol governance for authorization
2. Implement difficulty monitoring system
3. Submit regular updates via `update-difficulty`

### Oracle Responsibilities

- Monitor Bitcoin network difficulty adjustments (every ~2016 blocks)
- Submit accurate difficulty data within 24 hours of changes
- Maintain high uptime and reliability
- Follow protocol governance guidelines

## 🛡 Security Features

### Risk Management

- **Position Limits**: Maximum exposure per user
- **Liquidation Engine**: Automatic position closure for risk management
- **Circuit Breakers**: Contract pause functionality for emergencies
- **Oracle Verification**: Multi-signature oracle authorization

### Audit Status

- [ ] Initial security review
- [ ] Formal audit by [Audit Firm]
- [ ] Bug bounty program
- [ ] Mainnet deployment approval

## 🎯 Roadmap

### Phase 1: Core Protocol (Current)
- [x] Basic difficulty derivatives
- [x] Oracle system implementation
- [x] Position management
- [ ] Comprehensive testing

### Phase 2: Enhanced Features
- [ ] Hash rate derivatives
- [ ] Mempool congestion tracking
- [ ] Advanced risk management
- [ ] Governance token launch

### Phase 3: Cross-Chain Expansion
- [ ] Ethereum integration
- [ ] Multi-asset support
- [ ] Automated market making
- [ ] Institutional tools

### Phase 4: Ecosystem Growth
- [ ] Mobile application
- [ ] Analytics dashboard
- [ ] Third-party integrations
- [ ] Educational resources

## 🤝 Contributing

We welcome contributions from the community!

### Development Guidelines

1. Fork the repository
2. Create a feature branch
3. Write comprehensive tests
4. Follow Clarity best practices
5. Submit a pull request

### Areas for Contribution

- Smart contract optimizations
- Testing and security reviews
- Documentation improvements
- Oracle client development
- Frontend applications

## 📊 Protocol Metrics

### Current Stats (Testnet)

- **Total Value Locked**: $0 (Pre-launch)
- **Active Positions**: 0
- **Authorized Oracles**: 1
- **Average Difficulty Update Frequency**: Every 2016 Bitcoin blocks (~2 weeks)

### Key Metrics to Track

- Position volume and open interest
- Oracle uptime and accuracy
- Protocol revenue and fees
- User adoption and retention

## 🔍 Smart Contract Details

### Contract Address
- **Testnet**: `ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.rigrates`
- **Mainnet**: TBD

### Key Functions

| Function | Description | Access |
|----------|-------------|---------|
| `open-long-position` | Create bullish difficulty position | Public |
| `open-short-position` | Create bearish difficulty position | Public |
| `close-position` | Settle existing position | Public |
| `update-difficulty` | Submit difficulty data | Oracle Only |
| `add-oracle` | Authorize new oracle | Owner Only |
| `liquidate-position` | Force position closure | Oracle Only |

## ⚠️ Risks & Disclaimers

### Protocol Risks

- **Smart Contract Risk**: Potential bugs or vulnerabilities
- **Oracle Risk**: Dependency on external data providers
- **Market Risk**: High volatility in derivative positions
- **Liquidity Risk**: Potential difficulty in position exits

### Important Notes

- This is experimental DeFi technology
- Only invest what you can afford to lose
- Understand the risks before participating
- Smart contracts are immutable once deployed

### Getting Help

- Check the documentation first
- Search existing GitHub issues
- Join our Discord for real-time support
- Create detailed bug reports with reproduction steps


## 🙏 Acknowledgments

- Stacks Foundation for blockchain infrastructure
- Bitcoin Core developers for network data
- DeFi community for inspiration and feedback
- Early testers and contributors

