import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import {
  FeatureApiService,
  OrganizationSnapshot,
  SnapshotStatus,
  VacationExportRecord,
} from '../../core/feature-api.service';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-integrations',
  standalone: true,
  imports: [DatePipe],
  template: `
    <section class="feature-page" aria-labelledby="integrations-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">F-005 / synthetic simulator</p>
          <h2 id="integrations-title">Organization data and exports</h2>
        </div>
        <button class="button quiet" type="button" (click)="refresh()">Refresh status</button>
      </header>
      <p class="notice">
        Local synthetic snapshot and export outbox only. No ServiceNow, Active Directory, or
        external endpoint is called.
      </p>
      @if (error()) {
        <p class="notice error" role="alert">{{ error() }}</p>
      }
      @if (message()) {
        <p class="notice success" role="status">{{ message() }}</p>
      }

      <section class="subsection" aria-labelledby="snapshot-title">
        <div class="subsection-heading">
          <div>
            <p class="eyebrow">Atomic replacement</p>
            <h3 id="snapshot-title">Organization snapshot</h3>
          </div>
        </div>
        @if (snapshotStatus(); as snapshot) {
          <p class="snapshot-status">
            Version <strong>{{ snapshot.snapshotVersion }}</strong> ·
            {{ snapshot.stale ? 'Stale' : 'Current' }} · Generated
            {{ snapshot.generatedAt | date: 'medium' }}
          </p>
          @if (snapshot.validationErrors.length) {
            <ul class="validation-list">
              @for (item of snapshot.validationErrors; track item) {
                <li>{{ item }}</li>
              }
            </ul>
          }
        } @else {
          <p class="muted">Snapshot status is unavailable to this identity.</p>
        }
        <label class="field snapshot-editor">
          <span>Complete synthetic snapshot JSON</span>
          <textarea
            rows="14"
            spellcheck="false"
            [value]="snapshotJson()"
            (input)="snapshotJson.set(value($event))"
          ></textarea>
        </label>
        <div class="form-actions">
          <button class="button quiet" type="button" (click)="loadExample()">
            Load current fixture example
          </button>
          <button
            class="button primary"
            type="button"
            [disabled]="importing()"
            (click)="importSnapshot()"
          >
            {{ importing() ? 'Importing...' : 'Validate and import' }}
          </button>
        </div>
      </section>

      <section class="subsection" aria-labelledby="exports-title">
        <div class="subsection-heading">
          <div>
            <p class="eyebrow">Final Approved only</p>
            <h3 id="exports-title">Vacation export outbox</h3>
          </div>
          <div class="button-row">
            <button
              class="button quiet"
              type="button"
              [disabled]="evaluatingExports()"
              (click)="evaluateExports(false)"
            >
              Simulate successful delivery
            </button>
            <button
              class="button quiet"
              type="button"
              [disabled]="evaluatingExports()"
              (click)="evaluateExports(true)"
            >
              Simulate provider failure
            </button>
          </div>
        </div>
        @if (exports().length === 0) {
          <p class="muted">No approved vacation exports have been queued.</p>
        } @else {
          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th>Request</th>
                  <th>Version key</th>
                  <th>State</th>
                  <th>Attempts</th>
                  <th>Last attempt</th>
                </tr>
              </thead>
              <tbody>
                @for (record of exports(); track record.idempotencyKey) {
                  <tr>
                    <td>{{ record.requestId }}</td>
                    <td>{{ record.idempotencyKey }}</td>
                    <td>{{ record.status }}</td>
                    <td>{{ record.attemptCount }}</td>
                    <td>
                      {{
                        record.lastAttemptAt
                          ? (record.lastAttemptAt | date: 'medium')
                          : 'Not attempted'
                      }}
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
        }
      </section>
    </section>
  `,
})
export class IntegrationsComponent implements OnInit {
  private readonly api = inject(FeatureApiService);
  readonly session = inject(SessionService);
  readonly snapshotJson = signal('');
  readonly snapshotStatus = signal<SnapshotStatus | null>(null);
  readonly exports = signal<VacationExportRecord[]>([]);
  readonly importing = signal(false);
  readonly evaluatingExports = signal(false);
  readonly error = signal('');
  readonly message = signal('');

  ngOnInit(): void {
    this.loadExample();
    this.refresh();
  }

  loadExample(): void {
    const snapshot: OrganizationSnapshot = {
      snapshotVersion: `${this.snapshotStatus()?.snapshotVersion ?? 'test-v1-zz'}-manual-${Date.now()}`,
      generatedAt: new Date().toISOString(),
      department: { departmentId: 'DEPT-TEST-001', name: 'Synthetic Department' },
      employees: Array.from({ length: 10 }, (_, index) => ({
        employeeId: `EMP-TEST-${String(index + 1).padStart(3, '0')}`,
        active: true,
      })),
      projects: [
        { projectId: 'PRJ-TEST-ALPHA', departmentId: 'DEPT-TEST-001' },
        { projectId: 'PRJ-TEST-BETA', departmentId: 'DEPT-TEST-001' },
      ],
      memberships: Array.from({ length: 10 }, (_, index) => ({
        employeeId: `EMP-TEST-${String(index + 1).padStart(3, '0')}`,
        projectId: index < 6 ? 'PRJ-TEST-ALPHA' : 'PRJ-TEST-BETA',
      })),
      approverAssignments: [
        {
          scopeType: 'Project',
          scopeId: 'PRJ-TEST-ALPHA',
          approverId: 'EMP-TEST-009',
          role: 'ProjectApprover',
        },
        {
          scopeType: 'Project',
          scopeId: 'PRJ-TEST-BETA',
          approverId: 'EMP-TEST-010',
          role: 'ProjectApprover',
        },
        {
          scopeType: 'Department',
          scopeId: 'DEPT-TEST-001',
          approverId: 'EMP-TEST-008',
          role: 'DepartmentApprover',
        },
      ],
    };
    this.snapshotJson.set(JSON.stringify(snapshot, null, 2));
  }

  importSnapshot(): void {
    this.error.set('');
    this.message.set('');
    let snapshot: OrganizationSnapshot;
    try {
      snapshot = JSON.parse(this.snapshotJson()) as OrganizationSnapshot;
    } catch {
      this.error.set('The snapshot is not valid JSON.');
      return;
    }
    this.importing.set(true);
    this.api.importSnapshot(snapshot).subscribe({
      next: () => {
        this.importing.set(false);
        this.message.set('The complete snapshot was validated and published atomically.');
        this.session.loadProfile();
        this.refresh();
      },
      error: (failure: { status?: number; error?: { validationErrors?: string[] } }) => {
        this.importing.set(false);
        this.error.set(
          failure.error?.validationErrors?.join(' ') ??
            (failure.status === 409
              ? 'Snapshot version must be newer than the current valid snapshot.'
              : 'The snapshot was rejected; the last valid snapshot was retained.'),
        );
      },
    });
  }

  refresh(): void {
    this.api.getSnapshotStatus().subscribe({
      next: (status) => this.snapshotStatus.set(status),
      error: () => this.snapshotStatus.set(null),
    });
    this.api.listVacationExports().subscribe({
      next: (records) => this.exports.set(records),
      error: () => this.exports.set([]),
    });
  }

  evaluateExports(simulateFailure: boolean): void {
    this.evaluatingExports.set(true);
    this.error.set('');
    this.api.evaluateVacationExports(simulateFailure).subscribe({
      next: (result) => {
        this.evaluatingExports.set(false);
        this.message.set(
          `${result.processedCount} pending export(s) processed${simulateFailure ? ' with a simulated failure' : ''}.`,
        );
        this.refresh();
      },
      error: (failure: { status?: number }) => {
        this.evaluatingExports.set(false);
        this.error.set(
          failure.status === 403
            ? 'Only the department test operator can evaluate exports.'
            : 'The local export simulator is unavailable.',
        );
      },
    });
  }

  value(event: Event): string {
    return (event.target as HTMLTextAreaElement).value;
  }
}
