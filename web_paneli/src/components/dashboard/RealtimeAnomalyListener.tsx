'use client'
//
// src/components/dashboard/RealtimeAnomalyListener.tsx
//
// Hafta 9 — Supabase Realtime WebSocket Dinleyicisi
//
// Bu bileşen görünmez bir "listener"dır — hiçbir UI render etmez.
// Supabase'deki `anomalies` tablosuna yeni bir satır eklendiği an
// sonner toast.error() ile sağ üstte animasyonlu bildirim gösterir.
//
// Kullanım (Server Component içinde):
//   <RealtimeAnomalyListener userId={user.id} />
//

import { useEffect } from 'react'
import { toast }     from 'sonner'
import { createClient } from '@/lib/supabase/client'

// ─── Tip: anomalies tablosundan INSERT payload'ı ──────────────────────────────
interface AnomalyInsertPayload {
  id:             string
  user_id:        string
  description:    string
  detected_value: number
  expected_value: number
  severity:       'low' | 'medium' | 'high' | 'critical'
  status:         string
  created_at:     string
}

// ─── Şiddet rengi ve etiketi ──────────────────────────────────────────────────
const SEVERITY_LABEL: Record<string, string> = {
  low:      'Düşük',
  medium:   'Orta',
  high:     'Yüksek',
  critical: 'Kritik',
}

const SEVERITY_ICON: Record<string, string> = {
  low:      '🟡',
  medium:   '🟠',
  high:     '🔴',
  critical: '🚨',
}

// ─── Props ────────────────────────────────────────────────────────────────────
interface Props {
  /** Yalnızca giriş yapan kullanıcıya ait anomalileri dinle */
  userId: string
}

// ─── Bileşen ──────────────────────────────────────────────────────────────────
export default function RealtimeAnomalyListener({ userId }: Props) {
  useEffect(() => {
    const supabase = createClient()

    // Benzersiz kanal adı — birden fazla sekme açık olsa da çakışmaz
    const channelName = `realtime:anomalies:${userId}`

    const channel = supabase
      .channel(channelName)
      .on<AnomalyInsertPayload>(
        'postgres_changes',
        {
          event:  'INSERT',
          schema: 'public',
          table:  'anomalies',
          filter: `user_id=eq.${userId}`,   // sadece bu kullanıcının kayıtları
        },
        (payload) => {
          const row      = payload.new
          const icon     = SEVERITY_ICON[row.severity]  ?? '🚨'
          const sevLabel = SEVERITY_LABEL[row.severity] ?? row.severity
          const detected = Number(row.detected_value).toFixed(1)
          const expected = Number(row.expected_value).toFixed(1)

          // ── Sonner toast bildirimi ──────────────────────────────────────────
          toast.error('🚨 YENİ ANOMALİ TESPİTİ', {
            description: [
              `${icon} Şiddet: ${sevLabel}`,
              `📊 Tespit edilen: ${detected}  |  Normal: ${expected}`,
              `📝 ${row.description}`,
            ].join('\n'),
            duration:   8000,     // 8 saniye görünür
            id:         row.id,   // aynı anomali için tekrar bildirimi önle
          })

          console.info(
            `[RealtimeListener] ✅ Yeni anomali — id: ${row.id} | severity: ${row.severity}`,
          )
        },
      )
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          console.info(`[RealtimeListener] 🔌 WebSocket bağlandı: ${channelName}`)
        }
        if (status === 'CHANNEL_ERROR') {
          console.error(`[RealtimeListener] ❌ Kanal hatası: ${channelName}`)
        }
      })

    // Cleanup: bileşen unmount olduğunda kanalı kapat (bellek sızıntısı önleme)
    return () => {
      supabase.removeChannel(channel).catch(() => {
        // sessiz hata — unmount sonrası Supabase zaten kanalı kapatır
      })
      console.info(`[RealtimeListener] 🔌 WebSocket kapatıldı: ${channelName}`)
    }
  }, [userId]) // userId değişirse yeni abonelik kur

  // Bu bileşen hiçbir şey render etmez — sadece yan etki (side-effect) çalıştırır
  return null
}
