// src/app/dashboard/page.tsx
//
// Hafta 7 — EcoSync AI Command Center
// Server Component: Supabase'den veri çeker, Client bileşenlere prop olarak iletir.

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
  fetchAnomalyTrendPoints,
  fetchAnomalyStatusCounts,
} from '@/lib/supabase/anomaly_queries'

import ConsumptionAreaChart        from '@/components/ConsumptionAreaChart'
import AnomalyList                 from '@/components/AnomalyList'
import AnomalyTrendChart           from '@/components/dashboard/AnomalyTrendChart'
import AnomalyStatusPie            from '@/components/dashboard/AnomalyStatusPie'
import RealtimeAnomalyListener     from '@/components/dashboard/RealtimeAnomalyListener'

// ─── Yardımcı ─────────────────────────────────────────────────────────────────
function fmt(v: number): string {
  if (v === 0) return '—'
  return v % 1 === 0 ? v.toFixed(0) : v.toFixed(1)
}

// ─── Sayfa ────────────────────────────────────────────────────────────────────
export default async function DashboardPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const displayName =
    (user.user_metadata?.full_name as string) ?? user.email ?? 'Yönetici'

  // ── Server-side paralel veri çekme ────────────────────────────────────────
  const [
    totals,
    dailyData,
    recentAnomalies,
    openAnomalyCount,
    trendPoints,
    statusCounts,
  ] = await Promise.all([
    fetchConsumptionTotals(supabase, user.id, 30),
    fetchDailyConsumptions(supabase, user.id, 7),
    fetchRecentAnomalies(supabase, user.id, 10),
    fetchOpenAnomalyCount(supabase, user.id),
    fetchAnomalyTrendPoints(supabase, user.id, 30),
    fetchAnomalyStatusCounts(supabase, user.id),
  ])

  const hasOpenAnomalies = openAnomalyCount > 0
  const resolvedPct = statusCounts.total > 0
    ? Math.round((statusCounts.resolved / statusCounts.total) * 100)
    : 0

  // ── Özet stat kartları ────────────────────────────────────────────────────
  const statCards = [
    {
      label:  'Toplam Anomali',
      value:  String(statusCounts.total),
      sub:    'Tüm zamanlar',
      icon:   (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
          <path strokeLinecap="round" strokeLinejoin="round"
            d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126ZM12 15.75h.007v.008H12v-.008Z" />
        </svg>
      ),
      accent: 'text-amber-400',
      border: 'border-amber-500/20',
      bg:     'bg-amber-500/5',
    },
    {
      label:  'Açık Anomali',
      value:  String(openAnomalyCount),
      sub:    'Hemen kontrol et',
      icon:   (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
          <path strokeLinecap="round" strokeLinejoin="round"
            d="M14.857 17.082a23.848 23.848 0 0 0 5.454-1.31A8.967 8.967 0 0 1 18 9.75V9A6 6 0 0 0 6 9v.75a8.967 8.967 0 0 1-2.312 6.022c1.733.64 3.56 1.085 5.455 1.31m5.714 0a24.255 24.255 0 0 1-5.714 0m5.714 0a3 3 0 1 1-5.714 0" />
        </svg>
      ),
      accent: openAnomalyCount > 0 ? 'text-red-400' : 'text-slate-400',
      border: openAnomalyCount > 0 ? 'border-red-500/20' : 'border-white/10',
      bg:     openAnomalyCount > 0 ? 'bg-red-500/5'    : 'bg-white/5',
    },
    {
      label:  'Çözülme Oranı',
      value:  `%${resolvedPct}`,
      sub:    `${statusCounts.resolved} / ${statusCounts.total} çözüldü`,
      icon:   (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
          <path strokeLinecap="round" strokeLinejoin="round"
            d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
        </svg>
      ),
      accent: 'text-emerald-400',
      border: 'border-emerald-500/20',
      bg:     'bg-emerald-500/5',
    },
    {
      label:  'AI Analizi Yapılan',
      value:  String(recentAnomalies.filter((a) => a.gemini_explanation).length),
      sub:    'Son 10 anomalide',
      icon:   (
        <svg className="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={1.8}>
          <path strokeLinecap="round" strokeLinejoin="round"
            d="m3.75 13.5 10.5-11.25L12 10.5h8.25L9.75 21.75 12 13.5H3.75Z" />
        </svg>
      ),
      accent: 'text-violet-400',
      border: 'border-violet-500/20',
      bg:     'bg-violet-500/5',
    },
  ]

  const consumptionCards = [
    {
      label: 'Elektrik',   value: fmt(totals.electricity),
      unit: 'kWh (son 30 gün)', icon: '⚡',
      accent: 'text-amber-400', border: 'border-amber-500/20', bg: 'bg-amber-500/5',
    },
    {
      label: 'Su',         value: fmt(totals.water),
      unit: 'L (son 30 gün)',   icon: '💧',
      accent: 'text-blue-400',  border: 'border-blue-500/20',  bg: 'bg-blue-500/5',
    },
    {
      label: 'Gaz',        value: fmt(totals.gas),
      unit: 'm³ (son 30 gün)',  icon: '🔥',
      accent: 'text-orange-400', border: 'border-orange-500/20', bg: 'bg-orange-500/5',
    },
  ]

  return (
    <div className="min-h-screen bg-slate-950 text-white">

      {/* ── Header ──────────────────────────────────────────────────────────── */}
      <header className="border-b border-white/5 bg-slate-900/60 backdrop-blur-sm sticky top-0 z-20">
        <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 rounded-lg bg-emerald-500/20 border border-emerald-500/30 flex items-center justify-center">
              <svg className="w-4 h-4 text-emerald-400" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
                <path strokeLinecap="round" strokeLinejoin="round"
                  d="M12 3v2.25m6.364.386-1.591 1.591M21 12h-2.25m-.386 6.364-1.591-1.591M12 18.75V21m-4.773-4.227-1.591 1.591M5.25 12H3m4.227-4.773L5.636 5.636M15.75 12a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0Z" />
              </svg>
            </div>
            <span className="font-bold text-white">EcoSync AI</span>
            <span className="text-slate-500 text-sm">/ Command Center</span>
          </div>

          <div className="flex items-center gap-4">
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
              <span className="text-slate-300 text-sm hidden sm:block">{displayName}</span>
            </div>

            <form action={signOut}>
              <button
                type="submit"
                className="flex items-center gap-1.5 text-slate-400 hover:text-white text-sm transition-colors px-3 py-1.5 rounded-lg hover:bg-white/5"
              >
                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2}
                    d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
                </svg>
                Çıkış
              </button>
            </form>
          </div>
        </div>
      </header>

      {/* ── Ana İçerik ──────────────────────────────────────────────────────── */}
      <main className="max-w-7xl mx-auto px-6 py-8 space-y-10">

        {/* Karşılama */}
        <div>
          <h1 className="text-2xl font-bold text-white">Merhaba, {displayName} 👋</h1>
          <p className="text-slate-400 text-sm mt-1">
            EcoSync AI Komuta Merkezi&apos;ne hoş geldiniz. Tüm sistemler izleniyor.
          </p>
        </div>

        {/* ── KPI Stat Kartları ─────────────────────────────────────────────── */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-4">
            Sistem Özeti
          </h2>
          <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
            {statCards.map((card) => (
              <div
                key={card.label}
                className={`${card.bg} border ${card.border} rounded-2xl p-5 hover:bg-white/[0.07] transition-colors`}
              >
                <div className="flex items-center justify-between mb-3">
                  <span className="text-slate-400 text-xs font-medium">{card.label}</span>
                  <span className={card.accent}>{card.icon}</span>
                </div>
                <p className={`text-3xl font-bold ${card.accent}`}>{card.value}</p>
                <p className="text-slate-500 text-xs mt-1">{card.sub}</p>
              </div>
            ))}
          </div>
        </section>

        {/* ── Tüketim Özet Kartları ─────────────────────────────────────────── */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-4">
            Son 30 Gün — Tüketim Özeti
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {consumptionCards.map((card) => (
              <div
                key={card.label}
                className={`${card.bg} border ${card.border} rounded-2xl p-5 hover:bg-white/[0.07] transition-colors`}
              >
                <div className="flex items-center justify-between mb-3">
                  <span className="text-slate-400 text-sm font-medium">{card.label}</span>
                  <span className="text-xl">{card.icon}</span>
                </div>
                <p className={`text-3xl font-bold ${card.accent}`}>{card.value}</p>
                <p className="text-slate-500 text-xs mt-1">{card.unit}</p>
              </div>
            ))}
          </div>
        </section>

        {/* ── Hafta 7: İki Grafik — Yan Yana ──────────────────────────────── */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-4">
            Hafta 7 — Anomali Görselleştirme
          </h2>
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* LineChart 2/3 genişliğinde */}
            <div className="lg:col-span-2">
              <AnomalyTrendChart data={trendPoints} />
            </div>
            {/* Donut 1/3 genişliğinde */}
            <div className="lg:col-span-1">
              <AnomalyStatusPie
                counts={{
                  open:         statusCounts.open,
                  acknowledged: statusCounts.acknowledged,
                  resolved:     statusCounts.resolved,
                }}
                total={statusCounts.total}
              />
            </div>
          </div>
        </section>

        {/* ── Tüketim Alan Grafiği ──────────────────────────────────────────── */}
        <section>
          <h2 className="text-xs font-semibold text-slate-500 uppercase tracking-widest mb-4">
            Son 7 Gün — Tüketim Trendi
          </h2>
          <ConsumptionAreaChart data={dailyData} />
        </section>

        {/* ── Son Anomaliler Listesi ────────────────────────────────────────── */}
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

        {/* ── Alt Bilgi ─────────────────────────────────────────────────────── */}
        <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-2xl p-4 flex items-center gap-3">
          <span className="text-emerald-400 text-lg">✅</span>
          <div>
            <p className="text-emerald-400 text-sm font-medium">Canlı Supabase verisi aktif</p>
            <p className="text-slate-500 text-xs">
              Mobil uygulamadan eklenen kayıtlar bu panele otomatik yansır.
            </p>
          </div>
        </div>

        {/* ── Hafta 9: Realtime Listener — görünmez, sadece WebSocket dinler ── */}
        {/*
         * Server Component bu Client bileşeni render eder.
         * RealtimeAnomalyListener hiçbir DOM elementi üretmez (return null);
         * sadece Supabase Realtime kanalına abone olur ve yeni anomali
         * eklendiğinde sonner toast.error() ile bildirim gösterir.
         */}
        <RealtimeAnomalyListener userId={user.id} />

      </main>
    </div>
  )
}
