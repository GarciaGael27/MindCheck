export type UserRole = "student" | "tutor" | "admin";

export type BurnoutRiskLevel = "low" | "medium" | "high";

export type MBIDimension = "exhaustion" | "cynicism" | "efficacy";

export interface DailyCheckin {
  id: string;
  userId: string;
  mood: number;
  sleepHours: number;
  stressLevel: number;
  studyHours: number;
  notes?: string;
  createdAt: string;
}

export interface BurnoutScore {
  id: string;
  userId: string;
  riskLevel: BurnoutRiskLevel;
  probability: number;
  exhaustion: number;
  cynicism: number;
  efficacy: number;
  createdAt: string;
}
