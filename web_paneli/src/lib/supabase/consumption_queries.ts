// src/lib/supabase/consumption_queries.ts
//
// Server-side Supabase veri çekme fonksiyonları.
// Her fonksiyon saf (pure): girdi → çıktı, side-effect yok.
// Hata durumunda boş/sıfır değer döner — UI'ı patlatmaz.

import { SupabaseClient } from '@supabase/supabase-js'

// ─── Tipler ────────────────────────────────────────────────────────────────

export type ConsumptionType = 'electricity' | 'water' | 'gas'

export interface ConsumptionRow {
  id: string
  user_id: string
  type: ConsumptionType
  value: number
  unit: string
  recorded_at: string
  notes?: string | null
}

/** Özet kart değerleri: her tür için 30 günlük toplam */
export interface ConsumptionTotals {
  electricity: number
  water: number
  gas: number
}

/** Grafik için günlük nokta — her gün 3 seri */
export interface DailyPoint {
  date: string       // 'MM/DD' formatı
  electricity: number
  water: number
  gas: number
}

// ─── Yardımcı ───────────────────────────────────────────────────────────────

function isoToLabel(iso: string): string {
  const d = new Date(iso)
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${mm}/${dd}`
}

// ─── 1. Özet Toplamlar (30 gün) ─────────────────────────────────────────────

export async function fetchConsumptionTotals(
  supabase: SupabaseClient,
  userId: string,
  days = 30,
): Promise<ConsumptionTotals> {
  const since = new Date()
  since.setDate(since.getDate() - days)

  const { data, error } = await supabase
    .from('consumptions')
    .select('type, value')
    .eq('user_id', userId)
    .gte('recorded_at', since.toISOString())

  if (error || !data) {
    console.error('[fetchConsumptionTotals]', error)
    return { electricity: 0, water: 0, gas: 0 }
  }

  return (data as Pick<ConsumptionRow, 'type' | 'value'>[]).reduce(
    (acc, row) => ({
      ...acc,
      [row.type]: (acc[row.type as keyof ConsumptionTotals] ?? 0) + Number(row.value),
    }),
    { electricity: 0, water: 0, gas: 0 } as ConsumptionTotals,
  )
}

// ─── 2. Günlük Grafik Verisi (son N gün) ────────────────────────────────────

export async function fetchDailyConsumptions(
  supabase: SupabaseClient,
  userId: string,
  days = 7,
): Promise<DailyPoint[]> {
  const since = new Date()
  since.setDate(since.getDate() - days)

  const { data, error } = await supabase
    .from('consumptions')
    .select('type, value, recorded_at')
    .eq('user_id', userId)
    .gte('recorded_at', since.toISOString())
    .order('recorded_at', { ascending: true })

  if (error || !data) {
    console.error('[fetchDailyConsumptions]', error)
    return []
  }

  // Günlere göre gruplama (pure fold)
  const grouped = (
    data as Pick<ConsumptionRow, 'type' | 'value' | 'recorded_at'>[]
  ).reduce<Record<string, DailyPoint>>((acc, row) => {
    const label = isoToLabel(row.recorded_at)
    const existing = acc[label] ?? { date: label, electricity: 0, water: 0, gas: 0 }
    return {
      ...acc,
      [label]: {
        ...existing,
        [row.type]: existing[row.type as keyof Omit<DailyPoint, 'date'>] + Number(row.value),
      },
    }
  }, {})

  return Object.values(grouped)
}
