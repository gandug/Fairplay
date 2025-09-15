FairPlay Smart Contract

A **Clarity smart contract** that ensures **transparent, trustless, and verifiable reward distribution** for gaming and competition platforms on the Stacks blockchain.  
FairPlay enables game organizers to manage sessions, record participants, and automatically distribute rewards based on fair and immutable rules.

---

Features
- **Fair Rewards** – Automates prize allocation to winners without bias.  
- **Game Session Management** – Create and manage gaming or competition sessions.  
- **On-chain Auditing** – Full transparency and verifiability of sessions and rewards.  
- **Access Control** – Only authorized game organizers can manage sessions.  
- **Error Handling** – Prevents unauthorized actions, duplicate entries, and invalid sessions.  

---

Functions

Public Functions
- `create-session (rules string)` → Creates a new game session with defined rules.  
- `record-player (session-id uint player principal)` → Records a player’s participation.  
- `distribute-reward (session-id uint winner principal amount uint)` → Distributes rewards fairly to winners.  

Read-Only Functions
- `get-session (session-id uint)` → Retrieves session details.  
- `get-player-stats (player principal)` → Returns participation and reward history.  

---

Deployment

1. Clone the repository and navigate into the project directory:  
   ```bash
   git clone https://github.com/your-username/fairplay-contract.git
   cd fairplay-contract
