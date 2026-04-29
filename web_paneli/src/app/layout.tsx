import type { Metadata } from 'next'
import { Geist } from 'next/font/google'
import { Toaster } from 'sonner'
import './globals.css'

const geistSans = Geist({
  variable: '--font-geist-sans',
  subsets: ['latin'],
})

export const metadata: Metadata = {
  title: 'EcoSync AI — Yönetim Paneli',
  description:
    'EcoSync AI Akıllı Ekosistem Platformu — Yönetici kontrol paneli',
}

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode
}>) {
  return (
    <html lang="tr">
      <body className={`${geistSans.variable} antialiased`}>
        {children}
        {/*
         * Sonner Toaster — tüm uygulama genelinde aktif.
         * theme="dark"       → EcoSync koyu temasıyla uyumlu
         * position="top-right" → anomali bildirimleri sağ üstte belirir
         * richColors          → error() çağrısı otomatik kırmızı tonu alır
         * closeButton         → kullanıcı bildirimi elle kapatabilir
         */}
        <Toaster
          theme="dark"
          position="top-right"
          richColors
          closeButton
          toastOptions={{
            style: {
              background: '#0f172a',       /* slate-950 */
              border:     '1px solid rgba(239,68,68,0.25)',
              color:      '#f1f5f9',       /* slate-100 */
            },
          }}
        />
      </body>
    </html>
  )
}
