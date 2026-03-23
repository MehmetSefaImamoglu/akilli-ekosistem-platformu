'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export async function signIn(formData: FormData) {
  const supabase = await createClient()

  const email = formData.get('email') as string
  const password = formData.get('password') as string

  const { error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })

  if (error) {
    // Türkçe hata mesajları
    let message = 'Bir hata oluştu. Lütfen tekrar deneyin.'
    const msg = error.message.toLowerCase()

    if (msg.includes('invalid login credentials') || msg.includes('invalid credentials')) {
      message = 'E-posta veya şifre hatalı.'
    } else if (msg.includes('email not confirmed')) {
      message = 'E-posta adresiniz henüz doğrulanmamış.'
    } else if (msg.includes('too many requests')) {
      message = 'Çok fazla deneme yapıldı. Lütfen bekleyin.'
    }

    redirect(`/login?error=${encodeURIComponent(message)}`)
  }

  revalidatePath('/', 'layout')
  redirect('/dashboard')
}

export async function signOut() {
  const supabase = await createClient()
  await supabase.auth.signOut()
  revalidatePath('/', 'layout')
  redirect('/login')
}
