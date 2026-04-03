import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { signOut } from '@/app/auth/actions'
import {
  fetchConsumptionTotals,
  fetchDailyConsumptions,
} from '@/lib/supabase/consumption_queries'
import {
  fetchRecentAnomalies,
  fetchOpenAnomalyCount,
} from '@/lib/supabase/anomaly_queries'
import ConsumptionAreaChart from '@/components/ConsumptionAreaChart'
import AnomalyList from '@/components/AnomalyList'

// ─── Yardımcı: sayıyı güzel formatla ─────────────────────────────────────────
function fmt(v: number): string {
  if (v === 0) return '—'
  return v % 1 === 0 ? v.toFixed(0) : v.toFixed(1)
}

export default async function DashboardPage() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  const displayName =
    (user.user_metadata?.full_name as string) ?? user.email ?? 'Yonetici'

  // ── Server-side veri çekme ─────────────────────────────────────────────────
  const [totals, dailyData, recentAnomalies, openAnomalyCount] = await Promise.all([
    fetchConsumptionTotals(supabase, user.id, 30),
    fetchDailyConsumptions(supabase, user.id, 7),
    fetchRecentAnomalies(supabase, user.id, 10),
    fetchOpenAnomalyCount(supabase, user.id),
  ])

  const hasOpenAnomalies = openAnomalyCount > 0

  const summaryCards = [
    {
      label: 'Elektrik',
      value: fmt(totals.electricity),
      unit: 'kWh (son 30 gun)',
      icon: '⚡',
      accent: 'text-amber-400',
      border: 'border-amber-500/20',
      bg: 'bg-amber-500/5',
    },
    {
      label: 'Su',
      value: fmt(totals.water),
      unit: 'L (son 30 gun)',
      icon: '💧',
      accent: 'text-blue-400',
      border: 'border-blue-500/20',
      bg: 'bg-blue-500/5',
    },
    {
      label: 'Gaz',
      value: fmt(totals.gas),
      unit: 'm3 (son 30 gun)',
      icon: '🔥',
      accent: 'text-orange-400',
      border: 'border-orange-500/20',
      bg: 'bg-orange-500/5',
    },
  ]

  return (
    <div className="min-h-screen bg-slate-950 text-white">
      {/* Header */}
      <header className="border-b border-white/5 bg-slate-900/50 backdrop-blur-sm sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center">
              <svg
                className="w-4 h-4 text-emerald-400"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                strokeWidth={2}
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z"
                />
              </svg>
            </div>
            <span className="font-bold text-white">EcoSync AI</span>
            <span className="text-slate-500 text-sm">/ Dashboard</span>
          </div>

          <div className="flex items-center gap-4">
            {/* Açık anomali uyarı rozeti */}
            {hasOpenAnomalies && (
              <div className="flex items-center gap-1.5 bg-red-500/10 border border-red-500/30 rounded-full px-3 py-1">
                <span className="relative flex h-2 w-2">
                  <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-red-400 opacity-75" />
                  <span className="relative inline-flex rounded-full h-2 w-2 bg-red-500" />
                </span>
                <span className="text-red-300 text-xs font-semibold">
                  {openAnomalyCount} açık anomali
                </span>
              </div>
            )}

            <div className="flex items-center gap-2">
              <div className="w-7 h-7 rounded-full bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center text-xs font-bold text-emerald-400">
                {displayName.charAt(0).toUpperCase()}
              </div>
              <span className="text-slate-300 text-sm hidden sm:block">
                {displayName}
              </span>
            </div>

            <form action={signOut}>
              <button
                type="submit"
                className="flex items-center gap-1.5 text-slate-400 hover:text-white text-sm transition-colors px-3 py-1.5 rounded-lg hover:bg-white/5"
              >
                <svg
                  className="w-4 h-4"
                  fill="none"
                  viewBox="0 0 24 24"
                  stroke="currentColor"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth={2}
                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
                  />
                </svg>
                Cikis
              </button>
            </form>
          </div>
        </div>
      </header>

      {/* Ana Icerik */}
      <main className="max-w-7xl mx-auto px-6 py-8 space-y-8">
        {/* Karsilama */}
        <div>
          <h1 className="text-2xl font-bold text-white">
            Merhaba, {displayName} 👋
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            EcoSync AI Yonetim Paneline hos geldiniz.
          </p>
        </div>

        {/* Ozet Kartlar — gercek veriler */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-3">
            Son 30 Gun — Tuketim Ozeti
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {summaryCards.map((card) => (
              <div
                key={card.label}
                className={`${card.bg} border ${card.border} rounded-2xl p-5 hover:bg-white/[0.07] transition-colors`}
              >
                <div className="flex items-center justify-between mb-3">
                  <span className="text-slate-400 text-sm font-medium">
                    {card.label}
                  </span>
                  <span className="text-xl">{card.icon}</span>
                </div>
                <p className={`text-3xl font-bold ${card.accent}`}>
                  {card.value}
                </p>
                <p className="text-slate-500 text-xs mt-1">{card.unit}</p>
              </div>
            ))}
          </div>
        </section>

        {/* Recharts Alan Grafigi */}
        <section>
          <ConsumptionAreaChart data={dailyData} />
        </section>

        {/* ─── Son Anomaliler ─────────────────────────────────────────── */}
        <section>
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center gap-2">
              <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest">
                Son Anomaliler
              </h2>
              {hasOpenAnomalies && (
                <span className="text-xs font-bold px-2 py-0.5 rounded-full bg-red-500/20 text-red-300 border border-red-500/30">
                  {openAnomalyCount} açık
                </span>
              )}
            </div>
            <span className="text-xs text-slate-600">Son 10 kayıt</span>
          </div>

          {/* Anomali bulunan durum: kırmızı uyarı banner */}
          {hasOpenAnomalies && (
            <div className="flex items-center gap-3 bg-red-500/8 border border-red-500/25 rounded-xl px-4 py-3 mb-4">
              <span className="text-red-400 text-base select-none">🚨</span>
              <p className="text-red-300 text-sm">
                <strong>{openAnomalyCount} adet açık anomali</strong> mevcut — lütfen tüketim değerlerini inceleyin.
              </p>
            </div>
          )}

          <AnomalyList anomalies={recentAnomalies} />
        </section>

        {/* Alt bilgi */}
        <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-2xl p-4 flex items-center gap-3">
          <span className="text-emerald-400 text-lg">✅</span>
          <div>
            <p className="text-emerald-400 text-sm font-medium">
              Canli Supabase verisi aktif
            </p>
            <p className="text-slate-500 text-xs">
              Mobil uygulamadan eklenen kayitlar bu panele otomatik yansir.
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}
