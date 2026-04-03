// src/lib/supabase/anomaly_queries.ts
//
// Server-side Supabase anomali sorgulama fonksiyonları.
// Fonksiyonel Programlama ilkesi:
//   - Saf fonksiyonlar: girdi → çıktı, side-effect yok.
//   - Hata durumunda boş liste döner — UI patlamaz.
//   - Flutter'daki AnomalyRepository.fetchRecentAnomalies ile birebir aynı sorgu.

import { SupabaseClient } from '@supabase/supabase-js'

// ─── Tipler ─────────────────────────────────────────────────────────────────

export type AnomalySeverity = 'low' | 'medium' | 'high' | 'critical'
export type AnomalyStatus   = 'open' | 'acknowledged' | 'resolved'

export interface AnomalyRow {
  id:             string
  user_id:        string
  consumption_id: string | null
  description:    string
  severity:       AnomalySeverity
  status:         AnomalyStatus
  detected_value: number
  expected_value: number
  detected_at:    string   // ISO 8601
}

// ─── 1. Son N Anomaliyi Getir ────────────────────────────────────────────────

/**
 * Kullanıcıya ait en yeni [limit] adet anomaliyi azalan sırayla döndürür.
 * Flutter'daki fetchRecentAnomalies ile birebir aynı sorgu.
 */
export async function fetchRecentAnomalies(
  supabase: SupabaseClient,
  userId:   string,
  limit     = 10,
): Promise<AnomalyRow[]> {
  const { data, error } = await supabase
    .from('anomalies')
    .select('*')
    .eq('user_id', userId)
    .order('detected_at', { ascending: false })
    .limit(limit)

  if (error || !data) {
    console.error('[fetchRecentAnomalies]', error)
    return []
  }

  return data as AnomalyRow[]
}

// ─── 2. Açık Anomali Sayısı (özet kart için) ─────────────────────────────────

export async function fetchOpenAnomalyCount(
  supabase: SupabaseClient,
  userId:   string,
): Promise<number> {
  const { count, error } = await supabase
    .from('anomalies')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('status', 'open')

  if (error) {
    console.error('[fetchOpenAnomalyCount]', error)
    return 0
  }

  return count ?? 0
}

// ─── Yardımcı: severity → Türkçe etiket ──────────────────────────────────────

export function severityLabel(s: AnomalySeverity): string {
  const map: Record<AnomalySeverity, string> = {
    low:      'Düşük',
    medium:   'Orta',
    high:     'Yüksek',
    critical: 'Kritik',
  }
  return map[s] ?? s
}

// ─── Yardımcı: tarih formatla ─────────────────────────────────────────────────

export function formatDetectedAt(iso: string): string {
  const d = new Date(iso)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${pad(d.getDate())}.${pad(d.getMonth() + 1)}.${d.getFullYear()} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}
