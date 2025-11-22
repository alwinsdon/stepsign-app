import { useState } from 'react';
import { ArrowLeft, Calendar, Download, Share2, AlertCircle } from 'lucide-react';
import { Button } from './ui/button';
import { Badge } from './ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from './ui/tabs';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, Area, AreaChart } from 'recharts';

interface AnalyticsProps {
  onBack: () => void;
}

export function Analytics({ onBack }: AnalyticsProps) {
  const [timeRange, setTimeRange] = useState<'day' | 'week' | 'month'>('day');
  const [selectedDate, setSelectedDate] = useState(new Date());

  // Mock data for pressure over time
  const dayData = Array.from({ length: 24 }, (_, i) => ({
    hour: `${i}:00`,
    heel: Math.random() * 80 + 20,
    arch: Math.random() * 60 + 10,
    ball: Math.random() * 70 + 15,
    toes: Math.random() * 50 + 10,
  }));

  const weekData = Array.from({ length: 7 }, (_, i) => ({
    day: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][i],
    heel: Math.random() * 80 + 40,
    arch: Math.random() * 60 + 30,
    ball: Math.random() * 70 + 35,
    toes: Math.random() * 50 + 25,
  }));

  const monthData = Array.from({ length: 30 }, (_, i) => ({
    date: i + 1,
    heel: Math.random() * 80 + 40,
    arch: Math.random() * 60 + 30,
    ball: Math.random() * 70 + 35,
    toes: Math.random() * 50 + 25,
  }));

  const getCurrentData = () => {
    if (timeRange === 'day') return dayData;
    if (timeRange === 'week') return weekData;
    return monthData;
  };

  const getXAxisKey = () => {
    if (timeRange === 'day') return 'hour';
    if (timeRange === 'week') return 'day';
    return 'date';
  };

  return (
    <div className="min-h-screen max-w-md mx-auto p-6 pb-24">
      <div className="flex items-center gap-4 mb-6">
        <Button variant="ghost" size="icon" onClick={onBack} className="text-slate-400">
          <ArrowLeft className="w-5 h-5" />
        </Button>
        <div className="flex-1">
          <h1 className="text-white">Heatmap Analytics</h1>
          <p className="text-slate-400">Historical pressure data</p>
        </div>
        <Button variant="ghost" size="icon" className="text-slate-400">
          <Calendar className="w-5 h-5" />
        </Button>
      </div>

      {/* Time Range Selector */}
      <div className="grid grid-cols-3 gap-2 mb-6">
        <button
          onClick={() => setTimeRange('day')}
          className={`p-3 rounded-lg border transition-all ${
            timeRange === 'day'
              ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
              : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
          }`}
        >
          Day
        </button>
        <button
          onClick={() => setTimeRange('week')}
          className={`p-3 rounded-lg border transition-all ${
            timeRange === 'week'
              ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
              : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
          }`}
        >
          Week
        </button>
        <button
          onClick={() => setTimeRange('month')}
          className={`p-3 rounded-lg border transition-all ${
            timeRange === 'month'
              ? 'bg-cyan-500/20 border-cyan-500 text-cyan-400'
              : 'bg-slate-800/40 border-slate-700/50 text-slate-400'
          }`}
        >
          Month
        </button>
      </div>

      {/* Peak Pressure Alert */}
      <div className="p-4 bg-gradient-to-r from-amber-500/10 to-orange-500/10 rounded-xl border border-amber-500/30 mb-6">
        <div className="flex items-start gap-3">
          <AlertCircle className="w-5 h-5 text-amber-400 mt-0.5" />
          <div className="flex-1">
            <p className="text-amber-400 mb-1">Peak Pressure Alert</p>
            <p className="text-slate-400">Your heel pressure has been consistently high. Consider adding cushioning.</p>
          </div>
        </div>
      </div>

      {/* Tabs for different sensors */}
      <Tabs defaultValue="all" className="mb-6">
        <TabsList className="grid w-full grid-cols-5 mb-4">
          <TabsTrigger value="all">All</TabsTrigger>
          <TabsTrigger value="heel">Heel</TabsTrigger>
          <TabsTrigger value="arch">Arch</TabsTrigger>
          <TabsTrigger value="ball">Ball</TabsTrigger>
          <TabsTrigger value="toes">Toes</TabsTrigger>
        </TabsList>

        <TabsContent value="all" className="space-y-6">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <h3 className="text-slate-200 mb-4">All Regions — {timeRange === 'day' ? 'Today' : timeRange === 'week' ? 'This Week' : 'This Month'}</h3>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={getCurrentData()}>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey={getXAxisKey()} stroke="#94a3b8" />
                <YAxis stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: '1px solid #475569',
                    borderRadius: '8px',
                  }}
                />
                <Line type="monotone" dataKey="heel" stroke="#ef4444" strokeWidth={2} dot={false} />
                <Line type="monotone" dataKey="arch" stroke="#eab308" strokeWidth={2} dot={false} />
                <Line type="monotone" dataKey="ball" stroke="#f97316" strokeWidth={2} dot={false} />
                <Line type="monotone" dataKey="toes" stroke="#3b82f6" strokeWidth={2} dot={false} />
              </LineChart>
            </ResponsiveContainer>
            <div className="flex gap-4 justify-center mt-4">
              <div className="flex items-center gap-2">
                <div className="w-3 h-1 bg-red-500" />
                <span className="text-slate-400">Heel</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-1 bg-yellow-500" />
                <span className="text-slate-400">Arch</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-1 bg-orange-500" />
                <span className="text-slate-400">Ball</span>
              </div>
              <div className="flex items-center gap-2">
                <div className="w-3 h-1 bg-blue-500" />
                <span className="text-slate-400">Toes</span>
              </div>
            </div>
          </div>

          {/* Summary Stats */}
          <div className="grid grid-cols-2 gap-3">
            <div className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
              <p className="text-slate-400 mb-1">Avg Heel Pressure</p>
              <p className="text-white">62 N</p>
              <Badge variant="outline" className="mt-2 bg-red-500/10 text-red-400 border-red-500/50">
                High
              </Badge>
            </div>
            <div className="p-4 bg-slate-800/40 rounded-xl border border-slate-700/50">
              <p className="text-slate-400 mb-1">Avg Ball Pressure</p>
              <p className="text-white">48 N</p>
              <Badge variant="outline" className="mt-2 bg-green-500/10 text-green-400 border-green-500/50">
                Normal
              </Badge>
            </div>
          </div>
        </TabsContent>

        <TabsContent value="heel">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <h3 className="text-slate-200 mb-4">Heel Pressure</h3>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={getCurrentData()}>
                <defs>
                  <linearGradient id="heelGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#ef4444" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#ef4444" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey={getXAxisKey()} stroke="#94a3b8" />
                <YAxis stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: '1px solid #475569',
                    borderRadius: '8px',
                  }}
                />
                <Area type="monotone" dataKey="heel" stroke="#ef4444" fillOpacity={1} fill="url(#heelGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </TabsContent>

        <TabsContent value="arch">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <h3 className="text-slate-200 mb-4">Arch Pressure</h3>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={getCurrentData()}>
                <defs>
                  <linearGradient id="archGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#eab308" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#eab308" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey={getXAxisKey()} stroke="#94a3b8" />
                <YAxis stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: '1px solid #475569',
                    borderRadius: '8px',
                  }}
                />
                <Area type="monotone" dataKey="arch" stroke="#eab308" fillOpacity={1} fill="url(#archGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </TabsContent>

        <TabsContent value="ball">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <h3 className="text-slate-200 mb-4">Ball Pressure</h3>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={getCurrentData()}>
                <defs>
                  <linearGradient id="ballGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#f97316" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#f97316" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey={getXAxisKey()} stroke="#94a3b8" />
                <YAxis stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: '1px solid #475569',
                    borderRadius: '8px',
                  }}
                />
                <Area type="monotone" dataKey="ball" stroke="#f97316" fillOpacity={1} fill="url(#ballGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </TabsContent>

        <TabsContent value="toes">
          <div className="p-5 bg-slate-800/40 rounded-xl border border-slate-700/50">
            <h3 className="text-slate-200 mb-4">Toes Pressure</h3>
            <ResponsiveContainer width="100%" height={250}>
              <AreaChart data={getCurrentData()}>
                <defs>
                  <linearGradient id="toesGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.8}/>
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
                <XAxis dataKey={getXAxisKey()} stroke="#94a3b8" />
                <YAxis stroke="#94a3b8" />
                <Tooltip
                  contentStyle={{
                    backgroundColor: '#1e293b',
                    border: '1px solid #475569',
                    borderRadius: '8px',
                  }}
                />
                <Area type="monotone" dataKey="toes" stroke="#3b82f6" fillOpacity={1} fill="url(#toesGradient)" />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </TabsContent>
      </Tabs>

      {/* Export Actions */}
      <div className="grid grid-cols-2 gap-3">
        <Button variant="outline" className="border-slate-600 text-slate-300">
          <Download className="w-4 h-4 mr-2" />
          Export CSV
        </Button>
        <Button variant="outline" className="border-slate-600 text-slate-300">
          <Share2 className="w-4 h-4 mr-2" />
          Share Snapshot
        </Button>
      </div>
    </div>
  );
}
