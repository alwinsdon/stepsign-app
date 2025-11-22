import { useState } from 'react';
import { ArrowLeft, Wallet as WalletIcon, TrendingUp, TrendingDown, Lock, Send, Download, Copy, ExternalLink, Shield } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Input } from './ui/input';
import { Switch } from './ui/switch';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';

interface WalletProps {
  onBack: () => void;
}

export function Wallet({ onBack }: WalletProps) {
  const [stakedAmount] = useState(250);
  const [balance] = useState(12.5);
  const [isStaking, setIsStaking] = useState(false);
  const [stakeInput, setStakeInput] = useState('');
  const [is2FAEnabled, setIs2FAEnabled] = useState(true);
  const [walletAddress] = useState('0x742d...9A3f');

  const transactions = [
    { id: '0x1a2b...', type: 'reward', amount: 8.5, date: 'Nov 14, 2025', status: 'confirmed' },
    { id: '0x3c4d...', type: 'penalty', amount: -2.0, date: 'Nov 12, 2025', status: 'confirmed' },
    { id: '0x5e6f...', type: 'reward', amount: 12.0, date: 'Nov 11, 2025', status: 'confirmed' },
    { id: '0x7g8h...', type: 'stake', amount: -250, date: 'Nov 10, 2025', status: 'confirmed' },
    { id: '0x9i0j...', type: 'reward', amount: 6.2, date: 'Nov 9, 2025', status: 'pending' },
  ];

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button variant="ghost" size="icon" onClick={onBack} className="text-slate-400">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-white">Wallet</h1>
          <p className="text-slate-400">STEP Token Management</p>
        </div>
      </div>

      {/* Wallet Address Card */}
      <div className="p-5 bg-gradient-to-br from-amber-500/10 via-orange-500/10 to-pink-500/10 rounded-xl border border-amber-500/30 mb-6">
        <div className="flex items-center gap-3 mb-4">
          <div className="w-12 h-12 rounded-full bg-gradient-to-br from-amber-500 to-pink-600 flex items-center justify-center">
            <WalletIcon className="w-6 h-6 text-white" />
          </div>
          <div className="flex-1">
            <p className="text-slate-400">Wallet Address</p>
            <div className="flex items-center gap-2">
              <p className="text-white font-mono">{walletAddress}</p>
              <button
                onClick={() => copyToClipboard(walletAddress)}
                className="text-slate-400 hover:text-slate-200"
              >
                <Copy className="w-4 h-4" />
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Balance Overview */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
          <Lock className="w-5 h-5 text-amber-400 mb-2" />
          <p className="text-slate-400 mb-1">Staked</p>
          <p className="text-white">{stakedAmount} STEP</p>
          <p className="text-amber-400">Locked 30 days</p>
        </div>
        <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
          <WalletIcon className="w-5 h-5 text-green-400 mb-2" />
          <p className="text-slate-400 mb-1">Available</p>
          <p className="text-white">{balance} STEP</p>
          <p className="text-green-400">Ready to claim</p>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-2 gap-3 mb-6">
        <Button
          onClick={() => setIsStaking(true)}
          className="bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 text-white"
        >
          <Lock className="w-4 h-4 mr-2" />
          Stake More
        </Button>
        <Button
          variant="outline"
          className="border-slate-600 text-slate-300"
        >
          <Download className="w-4 h-4 mr-2" />
          Withdraw
        </Button>
      </div>

      {/* Stake Modal */}
      {isStaking && (
        <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50 mb-6">
          <div className="flex items-center justify-between mb-4">
            <p className="text-slate-200">Stake STEP Tokens</p>
            <button
              onClick={() => setIsStaking(false)}
              className="text-slate-400 hover:text-slate-200"
            >
              ✕
            </button>
          </div>
          
          <div className="space-y-4">
            <div>
              <label className="text-slate-400 mb-2 block">Amount to Stake</label>
              <Input
                type="number"
                value={stakeInput}
                onChange={(e) => setStakeInput(e.target.value)}
                placeholder="0.00"
                className="bg-slate-900/50 border-slate-600"
              />
            </div>

            <div className="p-4 bg-slate-900/50 rounded-lg border border-slate-700/50">
              <p className="text-slate-300 mb-3">Smart Contract Details:</p>
              <div className="space-y-2 text-slate-400">
                <div className="flex justify-between">
                  <span>Lock Period</span>
                  <span className="text-slate-200">30 days</span>
                </div>
                <div className="flex justify-between">
                  <span>Gas Fee (est.)</span>
                  <span className="text-slate-200">0.002 ETH</span>
                </div>
                <div className="flex justify-between">
                  <span>Penalty for Early Withdrawal</span>
                  <span className="text-red-400">10%</span>
                </div>
              </div>
            </div>

            <Button className="w-full bg-gradient-to-r from-amber-500 to-orange-600 hover:from-amber-600 hover:to-orange-700 text-white">
              Confirm Stake
            </Button>
          </div>
        </div>
      )}

      {/* Smart Contract Info */}
      <div className="p-4 bg-gradient-to-r from-blue-500/10 to-purple-500/10 rounded-xl border border-blue-500/30 mb-6">
        <div className="flex items-start gap-3">
          <Shield className="w-5 h-5 text-blue-400 mt-0.5" />
          <div className="flex-1">
            <p className="text-blue-400 mb-1">Smart Contract Verified</p>
            <p className="text-slate-400 mb-2">Contract: 0x1a2b...3c4d</p>
            <button className="flex items-center gap-1 text-blue-400 hover:text-blue-300">
              <span>View on Explorer</span>
              <ExternalLink className="w-3 h-3" />
            </button>
          </div>
        </div>
      </div>

      {/* Transactions */}
      <Tabs defaultValue="all" className="mb-6">
        <TabsList className="grid w-full grid-cols-3 mb-4">
          <TabsTrigger value="all">All</TabsTrigger>
          <TabsTrigger value="rewards">Rewards</TabsTrigger>
          <TabsTrigger value="penalties">Penalties</TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="space-y-3">
          <p className="text-slate-200 mb-3">Transaction History</p>
          {transactions.map((tx) => (
            <div
              key={tx.id}
              className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50"
            >
              <div className="flex items-start justify-between mb-2">
                <div className="flex items-center gap-3">
                  {tx.type === 'reward' && (
                    <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center">
                      <TrendingUp className="w-4 h-4 text-green-400" />
                    </div>
                  )}
                  {tx.type === 'penalty' && (
                    <div className="w-8 h-8 rounded-full bg-red-500/20 flex items-center justify-center">
                      <TrendingDown className="w-4 h-4 text-red-400" />
                    </div>
                  )}
                  {tx.type === 'stake' && (
                    <div className="w-8 h-8 rounded-full bg-amber-500/20 flex items-center justify-center">
                      <Lock className="w-4 h-4 text-amber-400" />
                    </div>
                  )}
                  <div>
                    <p className="text-slate-200 capitalize">{tx.type}</p>
                    <p className="text-slate-400">{tx.date}</p>
                  </div>
                </div>
                <div className="text-right">
                  <p
                    className={`${
                      tx.amount > 0 ? 'text-green-400' : 'text-red-400'
                    }`}
                  >
                    {tx.amount > 0 ? '+' : ''}{tx.amount} STEP
                  </p>
                  <Badge
                    variant="outline"
                    className={
                      tx.status === 'confirmed'
                        ? 'bg-green-500/10 text-green-400 border-green-500/50'
                        : 'bg-amber-500/10 text-amber-400 border-amber-500/50'
                    }
                  >
                    {tx.status}
                  </Badge>
                </div>
              </div>
              <div className="flex items-center gap-2">
                <p className="text-slate-500 font-mono">{tx.id}</p>
                <button
                  onClick={() => copyToClipboard(tx.id)}
                  className="text-slate-500 hover:text-slate-300"
                >
                  <Copy className="w-3 h-3" />
                </button>
                <button className="text-slate-500 hover:text-slate-300">
                  <ExternalLink className="w-3 h-3" />
                </button>
              </div>
            </div>
          ))}
        </TabsContent>

        <TabsContent value="rewards" className="space-y-3">
          <p className="text-slate-200 mb-3">Reward History</p>
          {transactions
            .filter((tx) => tx.type === 'reward')
            .map((tx) => (
              <div
                key={tx.id}
                className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-slate-200">Goal Verified</p>
                    <p className="text-slate-400">{tx.date}</p>
                  </div>
                  <p className="text-green-400">+{tx.amount} STEP</p>
                </div>
              </div>
            ))}
        </TabsContent>

        <TabsContent value="penalties" className="space-y-3">
          <p className="text-slate-200 mb-3">Penalty History</p>
          {transactions
            .filter((tx) => tx.type === 'penalty')
            .map((tx) => (
              <div
                key={tx.id}
                className="p-4 bg-slate-800/40 rounded-lg border border-slate-700/50"
              >
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-slate-200">Cheat Detection</p>
                    <p className="text-slate-400">{tx.date}</p>
                  </div>
                  <p className="text-red-400">{tx.amount} STEP</p>
                </div>
              </div>
            ))}
        </TabsContent>
      </Tabs>

      {/* Security Settings */}
      <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
        <p className="text-slate-200 mb-4">Security</p>
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Shield className="w-5 h-5 text-cyan-400" />
            <div>
              <p className="text-slate-200">Two-Factor Authentication</p>
              <p className="text-slate-400">Required for withdrawals</p>
            </div>
          </div>
          <Switch checked={is2FAEnabled} onCheckedChange={setIs2FAEnabled} />
        </div>
      </div>
    </div>
  );
}
