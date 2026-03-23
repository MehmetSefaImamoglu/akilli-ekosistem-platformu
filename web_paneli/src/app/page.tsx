import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

export default async function HomePage() {
  const supabase = await createClient()

  const {
    data: { user },
  } = await supabase.auth.getUser()

  // Giriş yapmışsa dashboard'a, yapmamışsa login'e
  if (user) {
    redirect('/dashboard')
  } else {
    redirect('/login')
  }
}
