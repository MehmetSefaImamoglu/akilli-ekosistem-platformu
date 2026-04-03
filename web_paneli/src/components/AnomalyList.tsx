// src/components/AnomalyList.tsx
//
// Sunucu Bileşeni — Turuncu/kırmızı tonlarında anomali kartları.
// Mobil Flutter kartlarının web karşılığı.
// Prop olarak hazır AnomalyRow[] alır (veri çekme işi yoktur).

import { AnomalyRow, AnomalySeverity, severityLabel, formatDetectedAt } from '@/lib/supabase/anomaly_queries'

// ─── Renk & ikon haritaları ───────────────────────────────────────────────────

const severityConfig: Record<
  AnomalySeverity,
  { border: string; bg: string; badge: string; dot: string; labelColor: string }
> = {
  low: {
    border:     'border-yellow-500/25',
    bg:         'bg-yellow-500/5',
    badge:      'bg-yellow-500/15 text-yellow-300 border border-yellow-500/30',
    dot:        'bg-yellow-400',
    labelColor: 'text-yellow-300',
  },
  medium: {
    border:     'border-orange-500/30',
    bg:         'bg-orange-500/8',
    badge:      'bg-orange-500/15 text-orange-300 border border-orange-500/30',
    dot:        'bg-orange-400',
    labelColor: 'text-orange-300',
  },
  high: {
    border:     'border-orange-600/40',
    bg:         'bg-orange-600/10',
    badge:      'bg-orange-600/20 text-orange-200 border border-orange-600/40',
    dot:        'bg-orange-500',
    labelColor: 'text-orange-200',
  },
  critical: {
    border:     'border-red-500/50',
    bg:         'bg-red-500/10',
    badge:      'bg-red-500/20 text-red-300 border border-red-500/40',
    dot:        'bg-red-500',
    labelColor: 'text-red-300',
  },
}

const statusConfig: Record<
  string,
  { label: string; classes: string }
> = {
  open:         { label: 'Açık',        classes: 'bg-red-500/15 text-red-300 border border-red-500/30' },
  acknowledged: { label: 'İnceleniyor', classes: 'bg-yellow-500/15 text-yellow-300 border border-yellow-500/30' },
  resolved:     { label: 'Çözüldü',     classes: 'bg-emerald-500/15 text-emerald-300 border border-emerald-500/30' },
}

// ─── Tek Kart ─────────────────────────────────────────────────────────────────

function AnomalyCard({ anomaly }: { anomaly: AnomalyRow }) {
  const cfg    = severityConfig[anomaly.severity] ?? severityConfig.high
  const stsCfg = statusConfig[anomaly.status]     ?? statusConfig.open
  const excess  = anomaly.detected_value - anomaly.expected_value
  const pct     = anomaly.expected_value > 0
    ? ((excess / anomaly.expected_value) * 100).toFixed(0)
    : '∞'

  return (
    <div
      className={`
        ${cfg.bg} border ${cfg.border} rounded-2xl p-4
        hover:brightness-110 transition-all duration-200
        group relative overflow-hidden
      `}
    >
      {/* Sol şerit aksan */}
      <div className={`absolute left-0 top-0 bottom-0 w-1 ${cfg.dot} rounded-l-2xl`} />

      <div className="pl-3">
        {/* Başlık satırı */}
        <div className="flex items-start justify-between gap-2 mb-2">
          <div className="flex items-center gap-2">
            {/* Uyarı ikonu */}
            <span className="text-lg select-none" aria-hidden>⚠️</span>
            <span className={`text-sm font-semibold leading-snug ${cfg.labelColor}`}>
              {anomaly.description}
            </span>
          </div>

          {/* Severity badge */}
          <span className={`shrink-0 text-xs font-bold px-2 py-0.5 rounded-full ${cfg.badge}`}>
            {severityLabel(anomaly.severity)}
          </span>
        </div>

        {/* Değer bilgisi */}
        <div className="flex items-center gap-4 text-xs text-slate-400 mb-3">
          <span>
            Tespit:{' '}
            <strong className="text-white">{anomaly.detected_value}</strong>
          </span>
          <span>
            Eşik:{' '}
            <strong className="text-slate-300">{anomaly.expected_value}</strong>
          </span>
          <span className={`font-bold ${cfg.labelColor}`}>
            +{pct}% aşım
          </span>
        </div>

        {/* Alt bilgi satırı */}
        <div className="flex items-center justify-between text-xs text-slate-500">
          <span>🕐 {formatDetectedAt(anomaly.detected_at)}</span>
          <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${stsCfg.classes}`}>
            {stsCfg.label}
          </span>
        </div>
      </div>
    </div>
  )
}

// ─── Ana Bileşen ──────────────────────────────────────────────────────────────

interface AnomalyListProps {
  anomalies: AnomalyRow[]
}

export default function AnomalyList({ anomalies }: AnomalyListProps) {
  if (anomalies.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center py-12 text-center">
        <span className="text-4xl mb-3 select-none" aria-hidden>✅</span>
        <p className="text-slate-400 text-sm font-medium">Anomali tespit edilmedi</p>
        <p className="text-slate-600 text-xs mt-1">
          Tüketim değerleri eşik sınırları içinde.
        </p>
      </div>
    )
  }

  return (
    <div className="space-y-3">
      {/* Özet sayaç */}
      <div className="flex items-center gap-2 mb-1">
        <span className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-red-500/20 border border-red-500/30 text-xs font-bold text-red-300">
          {anomalies.length}
        </span>
        <span className="text-xs text-slate-500">
          {anomalies.length === 1 ? '1 anomali' : `${anomalies.length} anomali`} listeleniyor
        </span>
      </div>

      {anomalies.map((a) => (
        <AnomalyCard key={a.id} anomaly={a} />
      ))}
    </div>
  )
}
