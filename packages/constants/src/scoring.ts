import type { BurnoutRiskLevel, MBIDimension } from "@mindcheck/types";

export interface DimensionCutoff {
  dimension: MBIDimension;
  lowThreshold: number;
  highThreshold: number;
}

export interface DimensionCutoffMap {
  exhaustion: { low: number; high: number };
  cynicism: { low: number; high: number };
  efficacy: { low: number; high: number };
}

/**
 * Classify a single dimension score against its population cutoffs.
 * Efficacy is reverse-scored: lower efficacy = higher burnout risk.
 */
export function classifyDimension(
  value: number,
  dimension: MBIDimension,
  cutoffs: DimensionCutoffMap,
): "low" | "medium" | "high" {
  const c = cutoffs[dimension];

  if (dimension === "efficacy") {
    if (value >= c.high) return "low";
    if (value <= c.low) return "high";
    return "medium";
  }

  if (value <= c.low) return "low";
  if (value >= c.high) return "high";
  return "medium";
}

/**
 * Combine three dimension classifications into an overall risk level.
 * Two or more 'high' dimensions → high risk.
 * One 'high' or any 'medium' → medium risk.
 * All 'low' → low risk.
 */
export function overallRisk(
  exhaustion: number,
  cynicism: number,
  efficacy: number,
  cutoffs: DimensionCutoffMap,
): BurnoutRiskLevel {
  const levels = [
    classifyDimension(exhaustion, "exhaustion", cutoffs),
    classifyDimension(cynicism, "cynicism", cutoffs),
    classifyDimension(efficacy, "efficacy", cutoffs),
  ];

  const highs = levels.filter((l) => l === "high").length;
  if (highs >= 2) return "high";
  if (highs === 1 || levels.includes("medium")) return "medium";
  return "low";
}

/**
 * Build a DimensionCutoffMap from rows fetched from the
 * `instrument_cutoffs` table (one row per dimension).
 */
export function cutoffsFromRows(
  rows: Array<{ dimension: string; low_threshold: number; high_threshold: number }>,
): DimensionCutoffMap {
  const map: Partial<DimensionCutoffMap> = {};
  for (const row of rows) {
    if (row.dimension === "exhaustion" || row.dimension === "cynicism" || row.dimension === "efficacy") {
      map[row.dimension] = { low: row.low_threshold, high: row.high_threshold };
    }
  }
  if (!map.exhaustion || !map.cynicism || !map.efficacy) {
    throw new Error("Faltan cutoffs para alguna dimensión del MBI-SS");
  }
  return map as DimensionCutoffMap;
}

/**
 * Compute the mean score per MBI-SS dimension from raw item responses.
 * Item-to-dimension mapping comes from the `instrument_items` table.
 */
export function computeDimensionMeans(
  responses: Array<{ item_number: number; value: number }>,
  itemDimensions: Map<number, MBIDimension>,
): { exhaustion: number; cynicism: number; efficacy: number } {
  const sums = { exhaustion: 0, cynicism: 0, efficacy: 0 };
  const counts = { exhaustion: 0, cynicism: 0, efficacy: 0 };

  for (const r of responses) {
    const dim = itemDimensions.get(r.item_number);
    if (!dim) continue;
    sums[dim] += r.value;
    counts[dim] += 1;
  }

  return {
    exhaustion: counts.exhaustion ? sums.exhaustion / counts.exhaustion : 0,
    cynicism: counts.cynicism ? sums.cynicism / counts.cynicism : 0,
    efficacy: counts.efficacy ? sums.efficacy / counts.efficacy : 0,
  };
}
