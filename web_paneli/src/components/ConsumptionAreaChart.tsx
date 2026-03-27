'use client'

// src/components/ConsumptionAreaChart.tsx
//
// Recharts AreaChart — son N günün tuketim serilerini cizer.
// Client Component: Recharts browser API kullanir.

import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
} from 'recharts'
import { DailyPoint } from '@/lib/supabase/consumption_queries'

interface Props {
  data: DailyPoint[]
}

const SERIES = [
  { key: 'electricity', label: 'Elektrik (kWh)', color: '#f59e0b' },
  { key: 'water',       label: 'Su (L)',          color: '#3b82f6' },
  { key: 'gas',         label: 'Gaz (m3)',         color: '#f97316' },
] as const

export default function ConsumptionAreaChart({ data }: Props) {
  if (data.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-52 rounded-2xl bg-white/5 border border-white/10 text-slate-500 gap-2">
        <svg className="w-10 h-10 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
            d="M3 13.5l4.5-4.5 3 3L15 8l4.5 4.5" />
        </svg>
        <p className="text-sm font-medium">Henuz kayit yok</p>
        <p className="text-xs">Mobil uygulamadan tuketim ekleyin</p>
      </div>
    )
  }

  return (
    <div className="rounded-2xl bg-white/5 border border-white/10 p-6">
      <h2 className="text-sm font-semibold text-slate-300 mb-4">
        Son 7 Gun — Tuketim Grafigi
      </h2>
      <ResponsiveContainer width="100%" height={260}>
        <AreaChart data={data} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
          <defs>
            {SERIES.map(({ key, color }) => (
              <linearGradient key={key} id={`grad-${key}`} x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%"  stopColor={color} stopOpacity={0.25} />
                <stop offset="95%" stopColor={color} stopOpacity={0.02} />
              </linearGradient>
            ))}
          </defs>

          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.06)" vertical={false} />

          <XAxis
            dataKey="date"
            tick={{ fill: '#94a3b8', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            tick={{ fill: '#94a3b8', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            tickCount={5}
          />

          <Tooltip
            contentStyle={{
              backgroundColor: '#1e293b',
              border: '1px solid rgba(255,255,255,0.1)',
              borderRadius: '12px',
              fontSize: '12px',
              color: '#e2e8f0',
            }}
            cursor={{ stroke: 'rgba(255,255,255,0.1)' }}
          />

          <Legend
            wrapperStyle={{ fontSize: '12px', color: '#94a3b8', paddingTop: '12px' }}
          />

          {SERIES.map(({ key, label, color }) => (
            <Area
              key={key}
              type="monotone"
              dataKey={key}
              name={label}
              stroke={color}
              strokeWidth={2}
              fill={`url(#grad-${key})`}
              dot={false}
              activeDot={{ r: 5, strokeWidth: 0 }}
            />
          ))}
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
