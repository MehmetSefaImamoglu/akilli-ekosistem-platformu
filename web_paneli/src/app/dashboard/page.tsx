import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { signOut } from '@/app/auth/actions'

export default async function DashboardPage() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Middleware bunu yakalamalıydı ama güvenlik için çift kontrol
  if (!user) {
    redirect('/login')
  }

  const displayName =
    (user.user_metadata?.full_name as string) ?? user.email ?? 'Yönetici'

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
                Çıkış
              </button>
            </form>
          </div>
        </div>
      </header>

      {/* Ana İçerik */}
      <main className="max-w-7xl mx-auto px-6 py-8">
        {/* Karşılama */}
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">
            Merhaba, {displayName} 👋
          </h1>
          <p className="text-slate-400 text-sm mt-1">
            EcoSync AI Yönetim Paneline hoş geldiniz.
          </p>
        </div>

        {/* Özet Kartlar */}
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
          {[
            {
              label: 'Elektrik',
              value: '—',
              unit: 'kWh',
              icon: '⚡',
              color: 'amber',
            },
            {
              label: 'Su',
              value: '—',
              unit: 'L',
              icon: '💧',
              color: 'blue',
            },
            {
              label: 'Gaz',
              value: '—',
              unit: 'm³',
              icon: '🔥',
              color: 'orange',
            },
          ].map((item) => (
            <div
              key={item.label}
              className="bg-white/5 border border-white/10 rounded-2xl p-5 hover:bg-white/[0.07] transition-colors"
            >
              <div className="flex items-center justify-between mb-3">
                <span className="text-slate-400 text-sm font-medium">
                  {item.label}
                </span>
                <span className="text-xl">{item.icon}</span>
              </div>
              <p className="text-2xl font-bold text-white">{item.value}</p>
              <p className="text-slate-500 text-xs mt-1">{item.unit}</p>
            </div>
          ))}
        </div>

        {/* Hafta 4 Notu */}
        <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-2xl p-6 text-center">
          <p className="text-emerald-400 font-medium">
            📊 Tüketim grafikleri ve anomali listesi Hafta 4&apos;te eklenecek
          </p>
          <p className="text-slate-500 text-sm mt-1">
            Auth entegrasyonu ✅ — Supabase bağlantısı aktif
          </p>
        </div>
      </main>
    </div>
  )
}
