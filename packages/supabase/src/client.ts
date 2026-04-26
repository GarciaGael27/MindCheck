import { createClient, type SupabaseClient } from "@supabase/supabase-js";
import type { Database } from "./database.types";

export type MindCheckClient = SupabaseClient<Database>;

export function createSupabaseClient(url: string, anonKey: string): MindCheckClient {
  return createClient<Database>(url, anonKey);
}
