'use client'

// src/components/dashboard/AnomalyTrendChart.tsx
//
// Hafta 7 — Anomali Tespit Graftği (LineChart)
// Aynı eksende detected_value (kırmızı) ve expected_value (yeşil kesikli)
// çizilerek anormal sapma gözle net biçimde görülür.

import {
  ComposedChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ReferenceLine,
  ResponsiveContainer,
} from 'recharts'

export interface AnomalyTrendPoint {
  date:           string   // "gg.AA" formatında
  detected_value: number
  expected_value: number
  severity:       string
}

interface Props {
  data: AnomalyTrendPoint[]
}

// ─── Özel Tooltip ─────────────────────────────────────────────────────────────
interface TooltipPayload {
  name:  string
  value: number
  color: string
}
interface CustomTooltipProps {
  active?:  boolean
  payload?: TooltipPayload[]
  label?:   string
}

function CustomTooltip({ active, payload, label }: CustomTooltipProps) {
  if (!active || !payload?.length) return null
  return (
    <div className="bg-slate-800 border border-white/10 rounded-xl px-4 py-3 shadow-2xl">
      <p className="text-slate-400 text-xs mb-2 font-medium">{label}</p>
      {payload.map((p) => (
        <div key={p.name} className="flex items-center gap-2 text-sm">
          <span
            className="w-2.5 h-2.5 rounded-full flex-shrink-0"
            style={{ backgroundColor: p.color }}
          />
          <span className="text-slate-300">{p.name}:</span>
          <span className="text-white font-semibold ml-auto pl-4">{p.value.toFixed(1)}</span>
        </div>
      ))}
    </div>
  )
}

// ─── Ana Bileşen ───────────────────────────────────────────────────────────────
export default function AnomalyTrendChart({ data }: Props) {
  if (data.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64 rounded-2xl bg-white/5 border border-white/10 text-slate-500 gap-3">
        <svg className="w-10 h-10 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
            d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        <p className="text-sm font-medium">Henüz anomali kaydı yok</p>
        <p className="text-xs">Eşik değeri aşımı tespit edildiğinde burada görünecek</p>
      </div>
    )
  }

  // En yüksek detected_value için referans çizgisi (max sapma noktası)
  const maxDetected = Math.max(...data.map((d) => d.detected_value))

  return (
    <div className="rounded-2xl bg-white/5 border border-white/10 p-6">
      {/* Başlık */}
      <div className="flex items-start justify-between mb-5">
        <div>
          <h2 className="text-sm font-semibold text-white">
            Anomali Tespit Grafiği
          </h2>
          <p className="text-xs text-slate-500 mt-0.5">
            Tespit edilen değer (kırmızı) vs. beklenen eşik (yeşil kesikli)
          </p>
        </div>
        <div className="flex items-center gap-1.5 bg-red-500/10 border border-red-500/20 rounded-full px-2.5 py-1">
          <span className="w-1.5 h-1.5 rounded-full bg-red-400 animate-pulse" />
          <span className="text-red-300 text-xs font-medium">{data.length} anomali</span>
        </div>
      </div>

      <ResponsiveContainer width="100%" height={280}>
        <ComposedChart data={data} margin={{ top: 8, right: 8, left: -16, bottom: 0 }}>
          <defs>
            <linearGradient id="grad-detected" x1="0" y1="0" x2="0" y2="1">
              <stop offset="5%"  stopColor="#ef4444" stopOpacity={0.2} />
              <stop offset="95%" stopColor="#ef4444" stopOpacity={0.0} />
            </linearGradient>
          </defs>

          <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.05)" vertical={false} />

          <XAxis
            dataKey="date"
            tick={{ fill: '#64748b', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
          />
          <YAxis
            tick={{ fill: '#64748b', fontSize: 11 }}
            axisLine={false}
            tickLine={false}
            tickCount={5}
          />

          <Tooltip content={<CustomTooltip />} cursor={{ stroke: 'rgba(255,255,255,0.08)' }} />

          <Legend
            wrapperStyle={{ fontSize: '12px', color: '#94a3b8', paddingTop: '14px' }}
          />

          {/* En yüksek sapma noktası için referans çizgisi */}
          <ReferenceLine
            y={maxDetected}
            stroke="#ef4444"
            strokeDasharray="4 4"
            strokeWidth={1}
            strokeOpacity={0.4}
            label={{ value: 'En yüksek', fill: '#ef4444', fontSize: 10, opacity: 0.6 }}
          />

          {/* Tespit edilen değer — kırmızı, keskin çizgi */}
          <Line
            type="monotone"
            dataKey="detected_value"
            name="Tespit Edilen"
            stroke="#ef4444"
            strokeWidth={2.5}
            dot={{ r: 4, fill: '#ef4444', strokeWidth: 0 }}
            activeDot={{ r: 6, strokeWidth: 0 }}
          />

          {/* Beklenen (eşik) değer — yeşil kesikli */}
          <Line
            type="monotone"
            dataKey="expected_value"
            name="Beklenen Eşik"
            stroke="#10b981"
            strokeWidth={2}
            strokeDasharray="6 3"
            dot={false}
            activeDot={{ r: 5, strokeWidth: 0 }}
          />
        </ComposedChart>
      </ResponsiveContainer>
    </div>
  )
}
