import type { Metadata } from 'next'
import { Geist } from 'next/font/google'
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
      <body className={`${geistSans.variable} antialiased`}>{children}</body>
    </html>
  )
}
