import { createClient } from '@supabase/supabase-js';

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

// Fallback logic to check if env keys are present, preventing crash during setup phase
const hasCredentials = supabaseUrl && supabaseAnonKey;

export const supabase = hasCredentials 
  ? createClient(supabaseUrl, supabaseAnonKey)
  : null;

// Helper to determine if we are operating in dynamic database mode
export const isSupabaseConfigured = (): boolean => {
  return !!supabase;
};
