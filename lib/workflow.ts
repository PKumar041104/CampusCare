export const PRIORITIES = ["LOW", "MEDIUM", "HIGH", "CRITICAL"] as const;
export const REQUEST_STATUSES = [
  "PENDING_APPROVAL",
  "APPROVED",
  "REJECTED",
  "REPORTED",
  "ASSIGNED",
  "IN_PROGRESS",
  "ON_HOLD",
  "RESOLVED",
  "CLOSED",
  "CANCELLED",
] as const;

export type RequestStatus = (typeof REQUEST_STATUSES)[number];

const technicianTransitions: Record<string, RequestStatus[]> = {
  ASSIGNED: ["IN_PROGRESS"],
  IN_PROGRESS: ["ON_HOLD", "RESOLVED"],
  ON_HOLD: ["IN_PROGRESS"],
};

export function canTechnicianTransition(current: string, next: string): boolean {
  return (technicianTransitions[current] || []).includes(next as RequestStatus);
}

export function parsePositiveId(value: FormDataEntryValue | null): number | null {
  const parsed = Number(value);
  return Number.isSafeInteger(parsed) && parsed > 0 ? parsed : null;
}

export function cleanText(value: FormDataEntryValue | null, maxLength: number): string {
  return String(value ?? "").trim().slice(0, maxLength);
}

export function isOneOf<T extends string>(value: string, choices: readonly T[]): value is T {
  return choices.includes(value as T);
}
