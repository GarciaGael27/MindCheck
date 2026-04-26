export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      admin_audit_log: {
        Row: {
          action: string
          admin_id: string
          created_at: string
          entity_id: string | null
          entity_type: string
          id: string
          ip_address: unknown
          payload: Json | null
        }
        Insert: {
          action: string
          admin_id: string
          created_at?: string
          entity_id?: string | null
          entity_type: string
          id?: string
          ip_address?: unknown
          payload?: Json | null
        }
        Update: {
          action?: string
          admin_id?: string
          created_at?: string
          entity_id?: string | null
          entity_type?: string
          id?: string
          ip_address?: unknown
          payload?: Json | null
        }
        Relationships: []
      }
      assessment_responses: {
        Row: {
          answered_at: string
          assessment_id: string
          id: string
          item_number: number
          value: number
        }
        Insert: {
          answered_at?: string
          assessment_id: string
          id?: string
          item_number: number
          value: number
        }
        Update: {
          answered_at?: string
          assessment_id?: string
          id?: string
          item_number?: number
          value?: number
        }
        Relationships: [
          {
            foreignKeyName: "assessment_responses_assessment_id_fkey"
            columns: ["assessment_id"]
            isOneToOne: false
            referencedRelation: "assessments"
            referencedColumns: ["id"]
          },
        ]
      }
      assessments: {
        Row: {
          abandoned_at: string | null
          completed_at: string | null
          duration_seconds: number | null
          id: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          started_at: string
          user_id: string
        }
        Insert: {
          abandoned_at?: string | null
          completed_at?: string | null
          duration_seconds?: number | null
          id?: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          started_at?: string
          user_id: string
        }
        Update: {
          abandoned_at?: string | null
          completed_at?: string | null
          duration_seconds?: number | null
          id?: string
          instrument?: Database["public"]["Enums"]["instrument_code"]
          started_at?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "assessments_instrument_fkey"
            columns: ["instrument"]
            isOneToOne: false
            referencedRelation: "instruments"
            referencedColumns: ["code"]
          },
        ]
      }
      burnout_scores: {
        Row: {
          algorithm_version: string
          assessment_id: string
          created_at: string
          cynicism: number
          efficacy: number
          exhaustion: number
          id: string
          probability: number | null
          risk_level: Database["public"]["Enums"]["burnout_risk_level"]
          user_id: string
        }
        Insert: {
          algorithm_version?: string
          assessment_id: string
          created_at?: string
          cynicism: number
          efficacy: number
          exhaustion: number
          id?: string
          probability?: number | null
          risk_level: Database["public"]["Enums"]["burnout_risk_level"]
          user_id: string
        }
        Update: {
          algorithm_version?: string
          assessment_id?: string
          created_at?: string
          cynicism?: number
          efficacy?: number
          exhaustion?: number
          id?: string
          probability?: number | null
          risk_level?: Database["public"]["Enums"]["burnout_risk_level"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "burnout_scores_assessment_id_fkey"
            columns: ["assessment_id"]
            isOneToOne: true
            referencedRelation: "assessments"
            referencedColumns: ["id"]
          },
        ]
      }
      consents: {
        Row: {
          consent_type: Database["public"]["Enums"]["consent_type"]
          granted: boolean
          granted_at: string
          id: string
          ip_address: unknown
          policy_version: string
          user_agent: string | null
          user_id: string
        }
        Insert: {
          consent_type: Database["public"]["Enums"]["consent_type"]
          granted: boolean
          granted_at?: string
          id?: string
          ip_address?: unknown
          policy_version: string
          user_agent?: string | null
          user_id: string
        }
        Update: {
          consent_type?: Database["public"]["Enums"]["consent_type"]
          granted?: boolean
          granted_at?: string
          id?: string
          ip_address?: unknown
          policy_version?: string
          user_agent?: string | null
          user_id?: string
        }
        Relationships: []
      }
      crisis_events: {
        Row: {
          acknowledged_at: string | null
          created_at: string
          id: string
          resources_shown: string[] | null
          severity: Database["public"]["Enums"]["crisis_severity"]
          source_id: string | null
          triggered_by: string
          user_id: string
        }
        Insert: {
          acknowledged_at?: string | null
          created_at?: string
          id?: string
          resources_shown?: string[] | null
          severity: Database["public"]["Enums"]["crisis_severity"]
          source_id?: string | null
          triggered_by: string
          user_id: string
        }
        Update: {
          acknowledged_at?: string | null
          created_at?: string
          id?: string
          resources_shown?: string[] | null
          severity?: Database["public"]["Enums"]["crisis_severity"]
          source_id?: string | null
          triggered_by?: string
          user_id?: string
        }
        Relationships: []
      }
      daily_checkins: {
        Row: {
          checkin_date: string
          created_at: string
          id: string
          mood: number
          notes: string | null
          sleep_hours: number | null
          stress_level: number | null
          study_hours: number | null
          user_id: string
        }
        Insert: {
          checkin_date?: string
          created_at?: string
          id?: string
          mood: number
          notes?: string | null
          sleep_hours?: number | null
          stress_level?: number | null
          study_hours?: number | null
          user_id: string
        }
        Update: {
          checkin_date?: string
          created_at?: string
          id?: string
          mood?: number
          notes?: string | null
          sleep_hours?: number | null
          stress_level?: number | null
          study_hours?: number | null
          user_id?: string
        }
        Relationships: []
      }
      instrument_cutoffs: {
        Row: {
          active: boolean
          created_at: string
          dimension: string
          high_threshold: number
          id: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          low_threshold: number
          notes: string | null
          population: string
        }
        Insert: {
          active?: boolean
          created_at?: string
          dimension: string
          high_threshold: number
          id?: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          low_threshold: number
          notes?: string | null
          population?: string
        }
        Update: {
          active?: boolean
          created_at?: string
          dimension?: string
          high_threshold?: number
          id?: string
          instrument?: Database["public"]["Enums"]["instrument_code"]
          low_threshold?: number
          notes?: string | null
          population?: string
        }
        Relationships: [
          {
            foreignKeyName: "instrument_cutoffs_instrument_fkey"
            columns: ["instrument"]
            isOneToOne: false
            referencedRelation: "instruments"
            referencedColumns: ["code"]
          },
        ]
      }
      instrument_item_history: {
        Row: {
          changed_at: string
          changed_by: string
          id: string
          item_id: string
          new_text: string
          previous_text: string
          reason: string
        }
        Insert: {
          changed_at?: string
          changed_by: string
          id?: string
          item_id: string
          new_text: string
          previous_text: string
          reason: string
        }
        Update: {
          changed_at?: string
          changed_by?: string
          id?: string
          item_id?: string
          new_text?: string
          previous_text?: string
          reason?: string
        }
        Relationships: [
          {
            foreignKeyName: "instrument_item_history_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "instrument_items"
            referencedColumns: ["id"]
          },
        ]
      }
      instrument_items: {
        Row: {
          created_at: string
          dimension: string | null
          id: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          item_number: number
          locked: boolean
          reverse_scored: boolean
          source_citation: string | null
          text: string
          updated_at: string
          version: number
        }
        Insert: {
          created_at?: string
          dimension?: string | null
          id?: string
          instrument: Database["public"]["Enums"]["instrument_code"]
          item_number: number
          locked?: boolean
          reverse_scored?: boolean
          source_citation?: string | null
          text: string
          updated_at?: string
          version?: number
        }
        Update: {
          created_at?: string
          dimension?: string | null
          id?: string
          instrument?: Database["public"]["Enums"]["instrument_code"]
          item_number?: number
          locked?: boolean
          reverse_scored?: boolean
          source_citation?: string | null
          text?: string
          updated_at?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "instrument_items_instrument_fkey"
            columns: ["instrument"]
            isOneToOne: false
            referencedRelation: "instruments"
            referencedColumns: ["code"]
          },
        ]
      }
      instruments: {
        Row: {
          active: boolean
          code: Database["public"]["Enums"]["instrument_code"]
          created_at: string
          description: string | null
          language: string
          name: string
          scale_max: number
          scale_min: number
          total_items: number
          updated_at: string
          validated_source: string | null
        }
        Insert: {
          active?: boolean
          code: Database["public"]["Enums"]["instrument_code"]
          created_at?: string
          description?: string | null
          language?: string
          name: string
          scale_max?: number
          scale_min?: number
          total_items: number
          updated_at?: string
          validated_source?: string | null
        }
        Update: {
          active?: boolean
          code?: Database["public"]["Enums"]["instrument_code"]
          created_at?: string
          description?: string | null
          language?: string
          name?: string
          scale_max?: number
          scale_min?: number
          total_items?: number
          updated_at?: string
          validated_source?: string | null
        }
        Relationships: []
      }
      notification_log: {
        Row: {
          channel: Database["public"]["Enums"]["notification_channel"]
          id: string
          opened_at: string | null
          sent_at: string
          template_code: string
          user_id: string
        }
        Insert: {
          channel: Database["public"]["Enums"]["notification_channel"]
          id?: string
          opened_at?: string | null
          sent_at?: string
          template_code: string
          user_id: string
        }
        Update: {
          channel?: Database["public"]["Enums"]["notification_channel"]
          id?: string
          opened_at?: string | null
          sent_at?: string
          template_code?: string
          user_id?: string
        }
        Relationships: []
      }
      profiles: {
        Row: {
          birth_year: number | null
          career: string | null
          created_at: string
          deleted_at: string | null
          display_name: string
          email: string
          gender: string | null
          id: string
          onboarded_at: string | null
          onboarding_step: number
          pronouns: string | null
          pseudonym: string | null
          role: Database["public"]["Enums"]["user_role"]
          semester: number | null
          show_real_name: boolean
          university: string | null
          updated_at: string
        }
        Insert: {
          birth_year?: number | null
          career?: string | null
          created_at?: string
          deleted_at?: string | null
          display_name: string
          email: string
          gender?: string | null
          id: string
          onboarded_at?: string | null
          onboarding_step?: number
          pronouns?: string | null
          pseudonym?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          semester?: number | null
          show_real_name?: boolean
          university?: string | null
          updated_at?: string
        }
        Update: {
          birth_year?: number | null
          career?: string | null
          created_at?: string
          deleted_at?: string | null
          display_name?: string
          email?: string
          gender?: string | null
          id?: string
          onboarded_at?: string | null
          onboarding_step?: number
          pronouns?: string | null
          pseudonym?: string | null
          role?: Database["public"]["Enums"]["user_role"]
          semester?: number | null
          show_real_name?: boolean
          university?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      resource_views: {
        Row: {
          helpful: boolean | null
          id: string
          resource_id: string
          user_id: string
          viewed_at: string
        }
        Insert: {
          helpful?: boolean | null
          id?: string
          resource_id: string
          user_id: string
          viewed_at?: string
        }
        Update: {
          helpful?: boolean | null
          id?: string
          resource_id?: string
          user_id?: string
          viewed_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "resource_views_resource_id_fkey"
            columns: ["resource_id"]
            isOneToOne: false
            referencedRelation: "resources"
            referencedColumns: ["id"]
          },
        ]
      }
      resources: {
        Row: {
          active: boolean
          body: string | null
          category: string
          created_at: string
          emergency: boolean
          id: string
          language: string
          title: string
          updated_at: string
          url: string | null
        }
        Insert: {
          active?: boolean
          body?: string | null
          category: string
          created_at?: string
          emergency?: boolean
          id?: string
          language?: string
          title: string
          updated_at?: string
          url?: string | null
        }
        Update: {
          active?: boolean
          body?: string | null
          category?: string
          created_at?: string
          emergency?: boolean
          id?: string
          language?: string
          title?: string
          updated_at?: string
          url?: string | null
        }
        Relationships: []
      }
      tutor_student_relationships: {
        Row: {
          accepted_at: string | null
          id: string
          invited_at: string
          revoked_at: string | null
          status: Database["public"]["Enums"]["tutor_relationship_status"]
          student_id: string
          tutor_id: string
        }
        Insert: {
          accepted_at?: string | null
          id?: string
          invited_at?: string
          revoked_at?: string | null
          status?: Database["public"]["Enums"]["tutor_relationship_status"]
          student_id: string
          tutor_id: string
        }
        Update: {
          accepted_at?: string | null
          id?: string
          invited_at?: string
          revoked_at?: string | null
          status?: Database["public"]["Enums"]["tutor_relationship_status"]
          student_id?: string
          tutor_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "tutor_student_relationships_student_id_fkey"
            columns: ["student_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "tutor_student_relationships_tutor_id_fkey"
            columns: ["tutor_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_preferences: {
        Row: {
          daily_reminder_at: string | null
          data_export_format: string
          notification_channels: Database["public"]["Enums"]["notification_channel"][]
          notifications_enabled: boolean
          preferred_language: string
          theme: string
          updated_at: string
          user_id: string
          weekly_assessment_day: number | null
        }
        Insert: {
          daily_reminder_at?: string | null
          data_export_format?: string
          notification_channels?: Database["public"]["Enums"]["notification_channel"][]
          notifications_enabled?: boolean
          preferred_language?: string
          theme?: string
          updated_at?: string
          user_id: string
          weekly_assessment_day?: number | null
        }
        Update: {
          daily_reminder_at?: string | null
          data_export_format?: string
          notification_channels?: Database["public"]["Enums"]["notification_channel"][]
          notifications_enabled?: boolean
          preferred_language?: string
          theme?: string
          updated_at?: string
          user_id?: string
          weekly_assessment_day?: number | null
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      is_active_tutor_of: { Args: { student: string }; Returns: boolean }
      is_admin: { Args: never; Returns: boolean }
    }
    Enums: {
      burnout_risk_level: "low" | "medium" | "high"
      consent_type:
        | "data_processing"
        | "research_use"
        | "tutor_sharing"
        | "anonymous_aggregation"
      crisis_severity: "watch" | "warning" | "urgent"
      instrument_code: "mbi_ss" | "pss_10" | "phq_9" | "gad_7"
      mbi_dimension: "exhaustion" | "cynicism" | "efficacy"
      notification_channel: "push" | "email" | "in_app"
      tutor_relationship_status: "pending" | "active" | "revoked"
      user_role: "student" | "tutor" | "admin"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      burnout_risk_level: ["low", "medium", "high"],
      consent_type: [
        "data_processing",
        "research_use",
        "tutor_sharing",
        "anonymous_aggregation",
      ],
      crisis_severity: ["watch", "warning", "urgent"],
      instrument_code: ["mbi_ss", "pss_10", "phq_9", "gad_7"],
      mbi_dimension: ["exhaustion", "cynicism", "efficacy"],
      notification_channel: ["push", "email", "in_app"],
      tutor_relationship_status: ["pending", "active", "revoked"],
      user_role: ["student", "tutor", "admin"],
    },
  },
} as const
