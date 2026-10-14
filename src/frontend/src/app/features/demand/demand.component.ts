import { Component, effect, inject, OnInit, signal, untracked } from '@angular/core';
import { DatePipe, DecimalPipe } from '@angular/common';
import { FeatureApiService, CapacityLimit, DemandSummary } from '../../core/feature-api.service';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-demand',
  standalone: true,
  imports: [DatePipe, DecimalPipe],
  template: `
    <section class="feature-page" aria-labelledby="demand-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">F-003 / direct scopes only</p>
          <h2 id="demand-title">Demand and capacity</h2>
        </div>
        <button class="button quiet" type="button" (click)="load()">Refresh</button>
      </header>

      <div class="query-bar">
        <label class="field"
          ><span>Scope</span>
          <select [value]="scopeType()" (change)="changeScopeType($event)">
            @if (canReadDepartment()) {
              <option value="Department">Department</option>
            }
            @if (canReadProject()) {
              <option value="Project">Project</option>
            }
          </select>
        </label>
        <label class="field"
          ><span>Organization</span>
          <select [value]="scopeId()" (change)="scopeId.set(value($event))">
            @for (scope of availableScopes(); track scope) {
              <option [value]="scope">{{ scope }}</option>
            }
          </select>
        </label>
        <label class="field"
          ><span>From</span
          ><input type="date" [value]="fromDate()" (input)="fromDate.set(value($event))"
        /></label>
        <label class="field"
          ><span>Through</span
          ><input type="date" [value]="toDate()" (input)="toDate.set(value($event))"
        /></label>
        <button class="button primary" type="button" [disabled]="loading()" (click)="load()">
          {{ loading() ? 'Loading...' : 'Calculate' }}
        </button>
      </div>

      @if (error()) {
        <p class="notice error" role="alert">{{ error() }}</p>
      }
      @if (summary(); as result) {
        <section class="metric-band" aria-label="Demand results">
          <div>
            <span>Active members</span><strong>{{ result.activeMemberCount }}</strong>
          </div>
          <div>
            <span>On approved vacation</span><strong>{{ result.peopleOnApprovedVacation }}</strong>
          </div>
          <div>
            <span>Demand</span
            ><strong>{{
              result.demandPercentage === null
                ? '—'
                : (result.demandPercentage | number: '1.0-1') + '%'
            }}</strong>
          </div>
          <div>
            <span>Data freshness</span><strong>{{ result.stale ? 'Stale' : 'Current' }}</strong>
          </div>
        </section>
        <div class="advisory-row">
          <p class="notice" [class.warning]="result.thresholdExceeded">
            {{
              result.thresholdExceeded
                ? 'Demand is at or above the 70% advisory marker.'
                : 'Demand is below the 70% advisory marker.'
            }}
          </p>
          <p class="notice" [class.warning]="result.capacityExceeded">
            {{
              result.capacityExceeded
                ? 'Approved demand exceeds the configured capacity advisory.'
                : 'No capacity advisory is exceeded.'
            }}
          </p>
        </div>
        <p class="as-of">
          Snapshot generated {{ result.dataAsOf | date: 'medium' }}. Demand is informational and
          never blocks a request.
        </p>
      }

      @if (canManageCapacity() && scopeType() === 'Department') {
        <section class="subsection" aria-labelledby="capacity-title">
          <div class="subsection-heading">
            <div>
              <p class="eyebrow">Department-only advisory</p>
              <h3 id="capacity-title">Capacity limits</h3>
            </div>
          </div>
          <form class="query-bar capacity-form" (submit)="$event.preventDefault(); saveLimit()">
            <label class="field"
              ><span>Period start</span
              ><input
                type="date"
                [value]="limitStart()"
                (input)="limitStart.set(value($event))"
                required
            /></label>
            <label class="field"
              ><span>Period end</span
              ><input
                type="date"
                [value]="limitEnd()"
                (input)="limitEnd.set(value($event))"
                required
            /></label>
            <label class="field"
              ><span>Maximum people</span
              ><input
                type="number"
                min="1"
                [value]="limitCount()"
                (input)="limitCount.set(Number(value($event)) || 1)"
                required
            /></label>
            <button class="button primary" type="submit" [disabled]="saving()">
              Save advisory
            </button>
          </form>
          @if (limits().length) {
            <div class="table-scroll">
              <table>
                <thead>
                  <tr>
                    <th>Period</th>
                    <th>Maximum people</th>
                    <th>Updated by</th>
                  </tr>
                </thead>
                <tbody>
                  @for (limit of limits(); track limit.id) {
                    <tr>
                      <td>{{ limit.periodStart }} to {{ limit.periodEnd }}</td>
                      <td>{{ limit.maxConcurrentPeople }}</td>
                      <td>{{ limit.updatedBy }}</td>
                    </tr>
                  }
                </tbody>
              </table>
            </div>
          } @else {
            <p class="muted">No capacity advisory is configured.</p>
          }
        </section>
      }
    </section>
  `,
})
export class DemandComponent implements OnInit {
  private readonly api = inject(FeatureApiService);
  readonly session = inject(SessionService);
  readonly today = new Date().toISOString().slice(0, 10);
  readonly fromDate = signal(this.today);
  readonly toDate = signal(this.addDays(this.today, 6));
  readonly limitStart = signal(this.today);
  readonly limitEnd = signal(this.addDays(this.today, 6));
  readonly limitCount = signal(3);
  readonly scopeType = signal<'Department' | 'Project'>('Project');
  readonly scopeId = signal('');
  readonly summary = signal<DemandSummary | null>(null);
  readonly limits = signal<CapacityLimit[]>([]);
  readonly loading = signal(false);
  readonly saving = signal(false);
  readonly error = signal('');
  private readonly profileInitialized = signal(false);

  constructor() {
    effect(() => {
      const profile = this.session.profile();
      if (!profile) {
        this.profileInitialized.set(false);
        return;
      }
      if (this.profileInitialized()) return;
      this.profileInitialized.set(true);
      if (profile.roles.includes('DepartmentApprover')) this.scopeType.set('Department');
      else this.scopeType.set('Project');
      this.scopeId.set(this.availableScopes()[0] ?? '');
      untracked(() => this.load());
    });
  }

  ngOnInit(): void {
    if (!this.session.profile()) this.session.loadProfile();
  }

  canReadDepartment(): boolean {
    return this.session.profile()?.roles.includes('DepartmentApprover') ?? false;
  }
  canReadProject(): boolean {
    return this.session.profile()?.roles.includes('ProjectApprover') ?? false;
  }
  canManageCapacity(): boolean {
    return this.canReadDepartment();
  }

  availableScopes(): string[] {
    const profile = this.session.profile();
    if (this.scopeType() === 'Department')
      return profile?.departmentId ? [profile.departmentId] : [];
    return profile?.projectIds ?? [];
  }

  changeScopeType(event: Event): void {
    this.scopeType.set(this.value(event) as 'Department' | 'Project');
    this.scopeId.set(this.availableScopes()[0] ?? '');
    this.load();
  }

  load(): void {
    if (!this.scopeId() || !this.fromDate() || !this.toDate()) return;
    this.loading.set(true);
    this.error.set('');
    this.api.getDemand(this.scopeType(), this.scopeId(), this.fromDate(), this.toDate()).subscribe({
      next: (summary) => {
        this.summary.set(summary);
        this.loading.set(false);
      },
      error: (failure: { status?: number }) => {
        this.summary.set(null);
        this.loading.set(false);
        this.error.set(
          failure.status === 403
            ? 'This identity cannot read demand in the selected scope.'
            : 'Demand could not be calculated.',
        );
      },
    });
    if (this.canManageCapacity() && this.scopeType() === 'Department') {
      this.api.listCapacityLimits(this.scopeType(), this.scopeId()).subscribe({
        next: (limits) => this.limits.set(limits),
        error: () => this.limits.set([]),
      });
    }
  }

  saveLimit(): void {
    this.saving.set(true);
    this.api
      .saveCapacityLimit({
        scopeType: 'Department',
        scopeId: this.session.profile()?.departmentId ?? '',
        periodStart: this.limitStart(),
        periodEnd: this.limitEnd(),
        maxConcurrentPeople: this.limitCount(),
      })
      .subscribe({
        next: () => {
          this.saving.set(false);
          this.load();
        },
        error: () => {
          this.saving.set(false);
          this.error.set('The advisory limit could not be saved.');
        },
      });
  }

  value(event: Event): string {
    return (event.target as HTMLInputElement).value;
  }
  Number(value: string): number {
    return Number(value);
  }

  private addDays(date: string, days: number): string {
    const value = new Date(`${date}T12:00:00`);
    value.setDate(value.getDate() + days);
    return value.toISOString().slice(0, 10);
  }
}
