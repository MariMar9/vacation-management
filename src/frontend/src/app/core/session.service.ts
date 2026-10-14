import { HttpClient } from '@angular/common/http';
import { inject, Injectable, signal } from '@angular/core';

export const SYNTHETIC_IDENTITIES = Array.from(
  { length: 10 },
  (_, index) => `EMP-TEST-${String(index + 1).padStart(3, '0')}`,
);

export interface AccessProfile {
  subjectId: string;
  active: boolean;
  departmentId: string;
  roles: string[];
  projectIds: string[];
  membershipProjectIds: string[];
  delegatableProjectIds: string[];
}

@Injectable({ providedIn: 'root' })
export class SessionService {
  private readonly http = inject(HttpClient);
  readonly identity = signal(this.readIdentity());
  readonly profile = signal<AccessProfile | null>(null);
  readonly loading = signal(false);
  readonly error = signal(false);

  selectIdentity(identity: string): void {
    if (!SYNTHETIC_IDENTITIES.includes(identity)) {
      return;
    }

    localStorage.setItem('vacation-test-identity', identity);
    this.identity.set(identity);
    this.profile.set(null);
    this.loadProfile();
  }

  loadProfile(): void {
    this.loading.set(true);
    this.error.set(false);
    this.http.get<AccessProfile>('/api/session/access').subscribe({
      next: (profile) => {
        this.profile.set(profile);
        this.loading.set(false);
      },
      error: () => {
        this.profile.set(null);
        this.error.set(true);
        this.loading.set(false);
      },
    });
  }

  private readIdentity(): string {
    const stored = localStorage.getItem('vacation-test-identity');
    return stored && SYNTHETIC_IDENTITIES.includes(stored) ? stored : SYNTHETIC_IDENTITIES[0];
  }
}
