// src/app/api/gemini/explain/route.ts
//
// Hafta 6 — Gemini AI Anomali Açıklama API Route'u
// SDK yok — fetch() ile doğrudan Google REST API.
// Model: gemini-2.5-flash
//
// ⚠️  KOK TAŞI NEDEN: gemini-2.5-flash bir "thinking" modelidir.
//     Varsayılan olarak thinking tokenları maxOutputTokens bütçesini
//     tüketir → yanıt için yalnızca ~60-80 token kalır → kesilir.
//     Çözüm: thinkingBudget: 0 → tüm tokenlar yanıta gider.

import { NextRequest, NextResponse } from 'next/server'
import { createAdminClient } from '@/lib/supabase/admin'

// ─── Tip tanımları ────────────────────────────────────────────────────────────
interface GeminiPart {
  text?:    string
  thought?: boolean   // thinking modellerinde düşünce parçaları buraya gelir
}
interface GeminiContent   { parts: GeminiPart[]; role: string }
interface GeminiCandidate { content: GeminiContent; finishReason: string }
interface GeminiResponse  {
  candidates?:    GeminiCandidate[]
  usageMetadata?: {
    promptTokenCount:     number
    candidatesTokenCount: number
    totalTokenCount:      number
    thoughtsTokenCount?:  number   // thinking token sayısı (varsa)
  }
  error?: { code: number; message: string; status: string }
}

// ─── Flutter'dan gelen istek ──────────────────────────────────────────────────
interface ExplainRequestBody {
  anomaly_id:     string
  description:    string
  detected_value: number
  expected_value: number
  severity:       string
}

// ─── CORS ─────────────────────────────────────────────────────────────────────
const CORS: HeadersInit = {
  'Access-Control-Allow-Origin':  '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
}

export async function OPTIONS(): Promise<NextResponse> {
  return new NextResponse(null, { status: 204, headers: CORS })
}

// ─── POST ─────────────────────────────────────────────────────────────────────
export async function POST(req: NextRequest): Promise<NextResponse> {

  // 1. API key
  const apiKey = process.env.GEMINI_API_KEY?.trim()
  if (!apiKey) {
    console.error('[gemini] ❌ GEMINI_API_KEY eksik.')
    return NextResponse.json(
      { error: 'GEMINI_API_KEY tanımlanmamış.' },
      { status: 500, headers: CORS },
    )
  }

  // 2. İstek gövdesi
  let body: ExplainRequestBody
  try {
    body = await req.json()
  } catch {
    return NextResponse.json({ error: 'Geçersiz JSON.' }, { status: 400, headers: CORS })
  }

  const { anomaly_id, description, detected_value, expected_value, severity } = body

  if (!anomaly_id || !description || detected_value == null || expected_value == null) {
    return NextResponse.json(
      { error: 'Eksik alan: anomaly_id, description, detected_value, expected_value' },
      { status: 422, headers: CORS },
    )
  }

  // 3. Prompt
  const deviationPct =
    expected_value > 0
      ? (((detected_value - expected_value) / expected_value) * 100).toFixed(1)
      : '?'

  const sevTr: Record<string, string> = {
    low: 'Düşük', medium: 'Orta', high: 'Yüksek', critical: 'Kritik',
  }

  const prompt =
`Sen profesyonel bir enerji tüketim analistinsin. EcoSync akıllı ev platformunda bir anomali tespit edildi.

Anomali Bilgileri:
- Olay: ${description}
- Ölçülen değer: ${detected_value}
- Normal eşik değeri: ${expected_value}
- Sapma oranı: %${deviationPct}
- Şiddet: ${sevTr[severity] ?? severity}

Görevin: Bu anomaliyi ev kullanıcısına Türkçe, anlaşılır ve profesyonel bir dille açıkla.

ZORUNLU KURALLAR:
1. En az 4 tam ve eksiksiz cümle yaz.
2. Anomalinin ne anlama geldiğini açıkla.
3. En az 2 olası teknik neden belirt.
4. Kullanıcının yapabileceği 1-2 pratik adım söyle.
5. Düz paragraf yaz; Markdown KULLANMA.
6. ASLA CÜMLE ORTASINDA DURMA.`

  // 4. Fetch isteği
  //
  //    JSON yapısı (birebir):
  //    {
  //      "contents": [...],           ← 1. seviye
  //      "generationConfig": {        ← 1. seviye (contents ile KARDEŞ)
  //        "maxOutputTokens": 2048,
  //        "thinkingConfig": {
  //          "thinkingBudget": 0      ← ANAHTAR FİX: thinking kapalı
  //        }
  //      }
  //    }
  //
  const GEMINI_URL =
    `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`

  const requestBody = {
    contents: [
      {
        parts: [{ text: prompt }],
      },
    ],
    generationConfig: {
      temperature:     0.7,
      maxOutputTokens: 2048,
      thinkingConfig: {
        thinkingBudget: 0,  // ← Thinking KAPALI: tüm 2048 token yanıta gider
      },
    },
  }


  let explanation: string
  try {
    const googleRes = await fetch(GEMINI_URL, {
      method:  'POST',
      headers: { 'Content-Type': 'application/json' },
      body:    JSON.stringify(requestBody),
    })

    const googleData = await googleRes.json() as GeminiResponse

    if (!googleRes.ok || googleData.error) {
      const msg = googleData.error?.message ?? `HTTP ${googleRes.status}`
      console.error(`[gemini] ❌ API Hatası ${googleRes.status}: ${msg}`)
      return NextResponse.json(
        { error: `Gemini API hatası (${googleRes.status}): ${msg}`, detail: googleData.error },
        { status: 502, headers: CORS },
      )
    }

    // Token kullanım raporu (sadece hata ayıklama için)
    const candidate    = googleData.candidates?.[0]
    const usage        = googleData.usageMetadata
    const finishReason = candidate?.finishReason ?? 'UNKNOWN'

    if (usage?.thoughtsTokenCount) {
      console.warn(`[gemini] Thinking tokenları: ${usage.thoughtsTokenCount} (thinkingBudget=0 aktif olmalı)`)
    }

    // Tüm parts'ları birleştir, thought olanları filtrele
    const parts = candidate?.content?.parts ?? []
    explanation = parts
      .filter((p) => !p.thought)           // thinking parçalarını at
      .map((p) => p.text ?? '')
      .join('')
      .trim()


    if (finishReason === 'MAX_TOKENS') {
      console.warn('[gemini] ⚠️  MAX_TOKENS — token bitti, metin kesildi!')
    }

    if (!explanation) {
      return NextResponse.json(
        { error: 'AI açıklama üretemedi.' },
        { status: 502, headers: CORS },
      )
    }

  } catch (err) {
    console.error('[gemini] ❌ Ağ hatası:', err)
    return NextResponse.json(
      { error: "Google API'ye ulaşılamadı." },
      { status: 503, headers: CORS },
    )
  }

  // 5. Supabase güncelle
  try {
    const admin = createAdminClient()
    const { error: dbErr } = await admin
      .from('anomalies')
      .update({
        gemini_explanation: explanation,
        gemini_analyzed_at: new Date().toISOString(),
      })
      .eq('id', anomaly_id)

    if (dbErr) {
      console.error('[gemini] ❌ Supabase yazma hatası:', dbErr.message)
      return NextResponse.json(
        { explanation, warning: `DB hatası: ${dbErr.message}` },
        { status: 207, headers: CORS },
      )
    }

    console.log(`[gemini] ✅ Supabase güncellendi — id: ${anomaly_id}`)
  } catch (err) {
    console.error('[gemini] ❌ Supabase bağlantı hatası:', err)
    return NextResponse.json(
      { explanation, warning: 'Veritabanı bağlantısı kurulamadı.' },
      { status: 207, headers: CORS },
    )
  }

  return NextResponse.json({ explanation }, { status: 200, headers: CORS })
}
