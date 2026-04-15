const Wallet = require('../../models/wallet/wallet.js');

// Get wallet for a user
exports.getWallet = async (req, res) => {
    try {
        const userId = req.params.userId;
        let wallet = await Wallet.findOne({ userId });
        if (!wallet) {
            // create wallet if not exists
            wallet = new Wallet({ userId });
            await wallet.save();
        }
        res.json(wallet);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Deposit money
exports.deposit = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { amount } = req.body;

        let wallet = await Wallet.findOne({ userId });
        if (!wallet) {
            wallet = new Wallet({ userId, balance: 0 });
        }

        wallet.balance += amount;
        await wallet.save();
        res.json({ balance: wallet.balance });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Withdraw money
exports.withdraw = async (req, res) => {
    try {
        const userId = req.params.userId;
        const { amount } = req.body;

        const wallet = await Wallet.findOne({ userId });
        if (!wallet) return res.status(404).json({ message: 'Wallet not found' });

        if (wallet.balance < amount) return res.status(400).json({ message: 'Insufficient balance' });

        wallet.balance -= amount;
        await wallet.save();
        res.json({ balance: wallet.balance });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};