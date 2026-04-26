// src/lib/supabase/admin.ts
//
// Supabase Admin (Service Role) istemcisi
//
// ⚠️ GÜVENLİK: Bu modül YALNIZCA Next.js API Route (server-side) içinden
// çağrılmalıdır. Service Role key'i hiçbir zaman istemci tarafına açmayın.
//
// Service Role = RLS politikalarını atlar.
// Kullanım amacı: Gemini API Route'un açıkladığı metni doğrudan
// anomalies tablosuna yazması (kullanıcı oturumu olmadan).

import { createClient } from '@supabase/supabase-js'

/**
 * RLS'i bypass eden admin Supabase istemcisi.
 * Yalnızca SUPABASE_SERVICE_ROLE_KEY ile çalışır.
 */
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY

  if (!url || !serviceKey) {
    throw new Error(
      '[createAdminClient] NEXT_PUBLIC_SUPABASE_URL veya SUPABASE_SERVICE_ROLE_KEY ' +
      'tanımlanmamış. .env.local dosyanızı kontrol edin.'
    )
  }

  return createClient(url, serviceKey, {
    auth: {
      // Service Role istemcisi oturum yönetimi yapmaz
      persistSession: false,
      autoRefreshToken: false,
    },
  })
}
