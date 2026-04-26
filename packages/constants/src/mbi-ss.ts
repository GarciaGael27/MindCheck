// Likert scale labels (UI only — items + cutoffs live in the database).
export const MBI_SS_SCALE = [
  { value: 0, label: "Nunca" },
  { value: 1, label: "Casi nunca" },
  { value: 2, label: "Algunas veces al año" },
  { value: 3, label: "Una vez al mes" },
  { value: 4, label: "Algunas veces al mes" },
  { value: 5, label: "Una vez por semana" },
  { value: 6, label: "Todos los días" },
] as const;

export type MBIScaleValue = (typeof MBI_SS_SCALE)[number]["value"];
