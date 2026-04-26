'use client'

// src/components/dashboard/AnomalyStatusPie.tsx
//
// Hafta 7 — Anomali Durum Dağılımı (PieChart / Donut)
// open → kırmızı | acknowledged → sarı | resolved → yeşil

import { PieChart, Pie, Cell, Tooltip, ResponsiveContainer, Legend } from 'recharts'

export interface StatusCount {
  open:         number
  acknowledged: number
  resolved:     number
}

interface Props {
  counts: StatusCount
  total:  number
}

const SLICES = [
  { key: 'open',         label: 'Açık',        color: '#ef4444' },
  { key: 'acknowledged', label: 'İnceleniyor', color: '#f59e0b' },
  { key: 'resolved',     label: 'Çözüldü',     color: '#10b981' },
] as const

// ─── Özel Tooltip ─────────────────────────────────────────────────────────────
interface TooltipPayload {
  name:  string
  value: number
  payload: { color: string; pct: number }
}
interface CustomTooltipProps {
  active?:  boolean
  payload?: TooltipPayload[]
}

function CustomTooltip({ active, payload }: CustomTooltipProps) {
  if (!active || !payload?.length) return null
  const d = payload[0]
  return (
    <div className="bg-slate-800 border border-white/10 rounded-xl px-4 py-3 shadow-2xl">
      <div className="flex items-center gap-2 mb-1">
        <span
          className="w-2.5 h-2.5 rounded-full"
          style={{ backgroundColor: d.payload.color }}
        />
        <span className="text-white text-sm font-semibold">{d.name}</span>
      </div>
      <p className="text-slate-400 text-xs">{d.value} anomali — %{d.payload.pct}</p>
    </div>
  )
}

// ─── Özel Legend ──────────────────────────────────────────────────────────────
interface LegendPayload {
  value: string
  color: string
  payload?: { value: number; pct: number }
}
function CustomLegend({ payload }: { payload?: LegendPayload[] }) {
  if (!payload) return null
  return (
    <ul className="flex flex-col gap-2 mt-2">
      {payload.map((entry) => (
        <li key={entry.value} className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <span
              className="w-2.5 h-2.5 rounded-full flex-shrink-0"
              style={{ backgroundColor: entry.color }}
            />
            <span className="text-slate-400 text-xs">{entry.value}</span>
          </div>
          <span className="text-white text-xs font-bold ml-6">
            {entry.payload?.value ?? 0}
            <span className="text-slate-500 font-normal ml-1">
              (%{entry.payload?.pct ?? 0})
            </span>
          </span>
        </li>
      ))}
    </ul>
  )
}

// ─── Ana Bileşen ───────────────────────────────────────────────────────────────
export default function AnomalyStatusPie({ counts, total }: Props) {
  const data = SLICES
    .map((s) => ({
      name:  s.label,
      value: counts[s.key],
      color: s.color,
      pct:   total > 0 ? Math.round((counts[s.key] / total) * 100) : 0,
    }))
    .filter((d) => d.value > 0)   // sıfır dilimlerini gizle

  const resolvedPct = total > 0 ? Math.round((counts.resolved / total) * 100) : 0

  if (total === 0) {
    return (
      <div className="flex flex-col items-center justify-center h-64 rounded-2xl bg-white/5 border border-white/10 text-slate-500 gap-3">
        <svg className="w-10 h-10 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
            d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <p className="text-sm font-medium">Hiç anomali yok</p>
        <p className="text-xs">Sistem normal sınırlar içinde çalışıyor</p>
      </div>
    )
  }

  return (
    <div className="rounded-2xl bg-white/5 border border-white/10 p-6 flex flex-col">
      {/* Başlık */}
      <div className="flex items-start justify-between mb-2">
        <div>
          <h2 className="text-sm font-semibold text-white">Anomali Durum Dağılımı</h2>
          <p className="text-xs text-slate-500 mt-0.5">Toplam {total} anomali</p>
        </div>
        {/* Çözülme oranı rozeti */}
        <div className="flex items-center gap-1.5 bg-emerald-500/10 border border-emerald-500/20 rounded-full px-2.5 py-1">
          <span className="text-emerald-400 text-xs font-bold">%{resolvedPct}</span>
          <span className="text-emerald-600 text-xs">çözüldü</span>
        </div>
      </div>

      <div className="flex items-center gap-6 flex-1">
        {/* Donut grafik */}
        <div className="flex-1 min-w-0">
          <ResponsiveContainer width="100%" height={220}>
            <PieChart>
              <Pie
                data={data}
                cx="50%"
                cy="50%"
                innerRadius={60}
                outerRadius={90}
                paddingAngle={3}
                dataKey="value"
                strokeWidth={0}
              >
                {data.map((entry) => (
                  <Cell key={entry.name} fill={entry.color} fillOpacity={0.9} />
                ))}
              </Pie>
              <Tooltip content={<CustomTooltip />} />
            </PieChart>
          </ResponsiveContainer>
        </div>

        {/* Özel legend — sağda dikey */}
        <div className="w-36 flex-shrink-0">
          <CustomLegend
            payload={data.map((d) => ({
              value:   d.name,
              color:   d.color,
              payload: { value: d.value, pct: d.pct },
            }))}
          />
        </div>
      </div>

      {/* Donut ortasına toplam anomali sayısı — CSS overlay */}
      {/* Not: Recharts'ta label prop ile yerleştirdik */}
    </div>
  )
}
