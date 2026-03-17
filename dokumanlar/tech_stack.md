# Teknoloji Yığını — EcoSync AI

> **Proje:** EcoSync AI (Akıllı Ekosistem Platformu)  
> **Versiyon:** 1.0.0  
> **Tarih:** Mart 2026  
> **Hazırlayan:** Mehmet Sefa İmamoğlu

---

## 1. Genel Bakış

Bu belge, EcoSync AI projesinde kullanılan tüm teknolojileri, seçilme gerekçelerini ve alternatiflerle karşılaştırmasını akademik düzeyde açıklamaktadır.

---

## 2. Web Frontend

| Teknoloji | Versiyon | Rol | Seçilme Gerekçesi |
|-----------|---------|-----|-------------------|
| **Next.js** | 14+ (App Router) | Web Çerçevesi | Server Components ile performanslı SSR/SSG; Vercel entegrasyonu; API Routes ile backend proxy |
| **TypeScript** | 5.x | Statik Tipleme | Derleme zamanı hata tespiti; büyük kod tabanlarında ölçeklenebilirlik |
| **Tailwind CSS** | 3.x | Stil Yönetimi | Utility-first yaklaşım ile hızlı prototipleme; tasarım tutarlılığı |
| **Recharts** | 2.x | Veri Görselleştirme | React ile native entegrasyon; responsive ve animasyonlu grafikler |
| **Supabase JS Client** | 2.x | Backend İletişim | Gerçek zamanlı subscriptionlar; tip güvenli sorgu builder |

### Alternatif Değerlendirmesi — Next.js vs. Vite/React

| Kriter | Next.js | Vite + React |
|--------|---------|-------------|
| SSR/SSG | ✅ Native | ❌ Ek yapılandırma gerekli |
| API Routes (Gemini proxy) | ✅ Dahili | ❌ Ayrı backend gerekli |
| Dosya tabanlı routing | ✅ | ❌ |
| Deployment (Vercel) | ✅ Sıfır config | Orta |

**Karar:** Next.js App Router tercih edildi. API Route'lar ile Gemini API anahtarı istemciden gizlenebilir.

---

## 3. Mobil Uygulama

| Teknoloji | Versiyon | Rol | Seçilme Gerekçesi |
|-----------|---------|-----|-------------------|
| **Flutter** | 3.19+ | Mobil Çerçeve | Tek kod tabanından iOS + Android; Material 3 desteği; yüksek performanslı widget motor |
| **Dart** | 3.3+ | Programlama Dili | Sıkı tip sistemi; async/await; null-safety |
| **Riverpod** | 2.x | State Management | Compile-time dependency injection; reaktif veri akışı; testlenebilirlik |
| **GoRouter** | 13.x | Navigasyon | Bildirimsel routing; deep link ve web URL desteği |
| **Supabase Flutter** | 2.x | Backend İletişim | Otomatik JWT yönetimi; realtime dinleyiciler |
| **fl_chart** | 0.68+ | Grafik | Native Flutter performansı; animasyonlu tüketim grafikleri |
| **flutter_dotenv** | 5.x | Env Yönetimi | `.env` dosyasından güvenli konfigürasyon yükleme |

### Alternatif Değerlendirmesi — Riverpod vs. Bloc vs. Provider

| Kriter | Riverpod | Bloc | Provider |
|--------|---------|------|----------|
| Boilerplate | Düşük | Yüksek | Orta |
| Test edilebilirlik | ✅ Çok İyi | ✅ Çok İyi | Orta |
| Code generation desteği | ✅ `riverpod_generator` | ✅ | ❌ |
| Compile-time güvenlik | ✅ | Orta | ❌ |
| Öğrenme eğrisi | Orta | Yüksek | Düşük |

**Karar:** Riverpod tercih edildi çünkü `riverpod_generator` ile kod üretimi, compile-time güvenlik ve minimum boilerplate sunar.

---

## 4. Backend — BaaS (Backend as a Service)

| Teknoloji | Versiyon | Rol | Seçilme Gerekçesi |
|-----------|---------|-----|-------------------|
| **Supabase** | Cloud | BaaS Platform | PostgreSQL + Auth + Realtime + Storage tek pakette; açık kaynak; ücretsiz tier |
| **PostgreSQL** | 15+ | İlişkisel Veritabanı | ACID uyumlu; JSON desteği; Row Level Security (RLS) |
| **Supabase Auth** | — | Kimlik Doğrulama | JWT tabanlı; OAuth provider desteği; RLS entegrasyonu |
| **Supabase Realtime** | — | Gerçek Zamanlı Güncellemeler | PostgreSQL logical replication üzeri WebSocket |

### Alternatif Değerlendirmesi — Supabase vs. Firebase

| Kriter | Supabase | Firebase |
|--------|---------|---------|
| Veritabanı | PostgreSQL (ilişkisel + SQL) | Firestore (NoSQL) |
| Sorgulama gücü | ✅ Tam SQL | ❌ Sınırlı |
| Açık Kaynak | ✅ Self-host mümkün | ❌ |
| Ücretsiz tier | Cömert | Orta |
| Gerçek zamanlı | ✅ | ✅ |

**Karar:** Supabase tercih edildi; karmaşık SQL sorguları (tüketim analizi için aggregationlar) ve RLS ile veri güvenliği kritik gereksinimlerdir.

---

## 5. Yapay Zeka Katmanı

| Teknoloji | Rol | Seçilme Gerekçesi |
|-----------|-----|-------------------|
| **Google Gemini API** (gemini-1.5-flash) | Anomali açıklama + Öneri üretme | Multimodal; hızlı; Türkçe dil desteği; ücretsiz tier |
| **Statistical Threshold Engine** | Anomali tespiti | Hafif, açıklanabilir, sezgisel eşik tabanlı tespit |

### Anomali Tespit Yaklaşımı

```
Tespit Yöntemi: Z-Score + Statik Eşik Kombinasyonu

1. Son 30 günlük hareketli ortalama hesapla (μ)
2. Standart sapma hesapla (σ)
3. Yeni değer z = (x - μ) / σ
4. |z| > 2.5 ise → Potansiyel anomali
5. Değer > statik_eşik ise → Kesin anomali
6. Gemini API ile İnsan Okunabilir Açıklama Üret
```

---

## 6. DevOps ve Araçlar

| Teknoloji | Rol |
|-----------|-----|
| **Git** | Versiyon kontrolü |
| **GitHub** | Uzak depo + Issue takibi |
| **Vercel** | Next.js web paneli dağıtımı (CI/CD dahil) |
| **Firebase App Distribution** | Flutter test dağıtımı |
| **ESLint + Prettier** | Web kod kalitesi |
| **flutter_lints** | Mobil kod kalitesi |

---

## 7. Bağımlılık Versiyonları (Snapshot — Mart 2026)

### Next.js (package.json)
```json
{
  "next": "^14.x",
  "react": "^18.x",
  "typescript": "^5.x",
  "tailwindcss": "^3.x",
  "@supabase/supabase-js": "^2.x"
}
```

### Flutter (pubspec.yaml)
```yaml
flutter_riverpod: ^2.5.1
supabase_flutter: ^2.5.3
go_router: ^13.2.0
fl_chart: ^0.68.0
google_generative_ai: ^0.4.3
flutter_dotenv: ^5.1.0
```
