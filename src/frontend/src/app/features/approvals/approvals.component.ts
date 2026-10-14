import { Component, effect, inject, OnInit, signal, untracked } from '@angular/core';
import { DatePipe } from '@angular/common';
import {
  FeatureApiService,
  ProjectDelegation,
  ReviewRequest,
} from '../../core/feature-api.service';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-approvals',
  standalone: true,
  imports: [DatePipe],
  template: `
    <section class="feature-page" aria-labelledby="approvals-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">F-002 / sequential review</p>
          <h2 id="approvals-title">Approval workbench</h2>
        </div>
        <button class="button quiet" type="button" (click)="load()">Refresh</button>
      </header>

      @if (!session.profile()) {
        <p class="notice">Select a synthetic identity with an approver role to continue.</p>
      } @else if (!canReviewProject() && !canReviewDepartment()) {
        <p class="notice">This identity has no approval scope.</p>
      } @else {
        <div class="tab-strip" role="tablist" aria-label="Approval level">
          @if (canReviewProject()) {
            <button
              type="button"
              role="tab"
              [attr.aria-selected]="level() === 'Project'"
              (click)="setLevel('Project')"
            >
              Project review
            </button>
          }
          @if (canReviewDepartment()) {
            <button
              type="button"
              role="tab"
              [attr.aria-selected]="level() === 'Department'"
              (click)="setLevel('Department')"
            >
              Department review
            </button>
          }
        </div>

        @if (level() === 'Project' && canManageProjectDelegation()) {
          <label class="field compact-field">
            <span>Assigned project</span>
            <select [value]="projectId()" (change)="selectProject($event)">
              @for (project of session.profile()?.projectIds ?? []; track project) {
                <option [value]="project">{{ project }}</option>
              }
            </select>
          </label>
        }

        @if (error()) {
          <p class="notice error" role="alert">{{ error() }}</p>
        }
        @if (message()) {
          <p class="notice success" role="status">{{ message() }}</p>
        }
        @if (loading()) {
          <p class="notice" role="status">Loading requests...</p>
        } @else if (requests().length === 0) {
          <p class="notice">No requests are awaiting this approval level.</p>
        } @else {
          <div class="request-queue">
            @for (request of requests(); track request.requestId) {
              <article class="queue-row">
                <div class="queue-summary">
                  <p class="eyebrow">
                    {{ request.projectId }} · {{ request.approvalLevel }} decision
                  </p>
                  <h3>{{ request.startDate }} to {{ request.endDate }}</h3>
                  <p>Requester {{ request.requesterId }} · version {{ request.version }}</p>
                </div>
                <div class="queue-actions">
                  <label class="field reject-reason">
                    <span>Rejection reason <small>Required only to reject</small></span>
                    <input
                      maxlength="500"
                      [value]="reasonFor(request.requestId)"
                      (input)="setReason(request.requestId, $event)"
                    />
                  </label>
                  <div class="button-row">
                    <button
                      class="button primary"
                      type="button"
                      [disabled]="saving() === request.requestId"
                      (click)="decide(request, 'Approved')"
                    >
                      Approve
                    </button>
                    <button
                      class="button danger"
                      type="button"
                      [disabled]="
                        saving() === request.requestId || !reasonFor(request.requestId).trim()
                      "
                      (click)="decide(request, 'Rejected')"
                    >
                      Reject
                    </button>
                  </div>
                </div>
              </article>
            }
          </div>
        }

        @if (level() === 'Project' && canReviewProject()) {
          <section class="subsection" aria-labelledby="delegation-title">
            <div class="subsection-heading">
              <div>
                <p class="eyebrow">Project-scoped, 1–30 days</p>
                <h3 id="delegation-title">Delegation</h3>
              </div>
              <button class="button quiet" type="button" (click)="loadDelegations()">
                Refresh
              </button>
            </div>
            <form class="delegation-form" (submit)="$event.preventDefault(); grantDelegation()">
              <label class="field">
                <span>Delegate identity</span>
                <input
                  required
                  pattern="EMP-TEST-[A-Z0-9-]+"
                  [value]="delegateId()"
                  (input)="delegateId.set(inputValue($event))"
                  placeholder="EMP-TEST-002"
                />
              </label>
              <label class="field days-field">
                <span>Duration (days)</span>
                <input
                  type="number"
                  min="1"
                  max="30"
                  [value]="durationDays()"
                  (input)="durationDays.set(Number(inputValue($event)) || 1)"
                />
              </label>
              <button class="button primary" type="submit" [disabled]="saving() === 'delegation'">
                Grant delegation
              </button>
            </form>
            @if (delegationError()) {
              <p class="notice error" role="alert">{{ delegationError() }}</p>
            }
            @if (delegations().length > 0) {
              <div class="table-scroll">
                <table>
                  <thead>
                    <tr>
                      <th>Delegate</th>
                      <th>Starts</th>
                      <th>Expires</th>
                      <th>Status</th>
                      <th></th>
                    </tr>
                  </thead>
                  <tbody>
                    @for (delegation of delegations(); track delegation.id) {
                      <tr>
                        <td>{{ delegation.delegateId }}</td>
                        <td>{{ delegation.startsAt | date: 'mediumDate' }}</td>
                        <td>{{ delegation.expiresAt | date: 'mediumDate' }}</td>
                        <td>{{ delegation.status }}</td>
                        <td>
                          @if (
                            delegation.status === 'Active' &&
                            delegation.delegatorId === session.identity()
                          ) {
                            <button class="text-action" type="button" (click)="revoke(delegation)">
                              Revoke
                            </button>
                          }
                        </td>
                      </tr>
                    }
                  </tbody>
                </table>
              </div>
            }
          </section>
        }
      }
    </section>
  `,
})
export class ApprovalsComponent implements OnInit {
  private readonly api = inject(FeatureApiService);
  readonly session = inject(SessionService);
  readonly level = signal<'Project' | 'Department'>('Project');
  readonly projectId = signal('');
  readonly requests = signal<ReviewRequest[]>([]);
  readonly delegations = signal<ProjectDelegation[]>([]);
  readonly reasons = signal<Record<string, string>>({});
  readonly delegateId = signal('');
  readonly durationDays = signal(7);
  readonly loading = signal(false);
  readonly saving = signal('');
  readonly error = signal('');
  readonly delegationError = signal('');
  readonly message = signal('');
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
      if (
        !profile.roles.includes('ProjectApprover') &&
        profile.roles.includes('DepartmentApprover')
      ) {
        this.level.set('Department');
      } else {
        this.level.set('Project');
      }
      this.projectId.set(profile.projectIds[0] ?? '');
      untracked(() => this.load());
    });
  }

  ngOnInit(): void {
    if (!this.session.profile()) this.session.loadProfile();
  }

  canReviewProject(): boolean {
    return this.session.profile()?.roles.includes('ProjectApprover') ?? false;
  }

  canReviewDepartment(): boolean {
    return this.session.profile()?.roles.includes('DepartmentApprover') ?? false;
  }

  canManageProjectDelegation(): boolean {
    return this.session.profile()?.delegatableProjectIds.includes(this.projectId()) ?? false;
  }

  setLevel(level: 'Project' | 'Department'): void {
    this.level.set(level);
    this.message.set('');
    this.load();
  }

  selectProject(event: Event): void {
    this.projectId.set(this.inputValue(event));
    this.load();
    this.loadDelegations();
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    const request =
      this.level() === 'Project'
        ? this.api.listProjectRequests(this.projectId())
        : this.api.listDepartmentRequests();
    request.subscribe({
      next: (items) => {
        this.requests.set(items);
        this.loading.set(false);
        if (this.level() === 'Project') this.loadDelegations();
      },
      error: (failure: { status?: number }) => {
        this.requests.set([]);
        this.loading.set(false);
        this.error.set(
          failure.status === 403
            ? 'This identity cannot review the selected scope.'
            : 'The review queue could not be loaded.',
        );
      },
    });
  }

  loadDelegations(): void {
    if (!this.projectId() || !this.canManageProjectDelegation()) {
      this.delegations.set([]);
      return;
    }
    this.api.listDelegations(this.projectId()).subscribe({
      next: (items) => this.delegations.set(items),
      error: () => this.delegations.set([]),
    });
  }

  reasonFor(requestId: string): string {
    return this.reasons()[requestId] ?? '';
  }

  setReason(requestId: string, event: Event): void {
    this.reasons.update((reasons) => ({ ...reasons, [requestId]: this.inputValue(event) }));
  }

  decide(request: ReviewRequest, outcome: 'Approved' | 'Rejected'): void {
    const reason = this.reasonFor(request.requestId).trim();
    if (outcome === 'Rejected' && !reason) return;
    this.saving.set(request.requestId);
    this.error.set('');
    this.api
      .decideRequest(
        request,
        this.level() === 'Project' ? 'project' : 'department',
        outcome,
        reason || null,
      )
      .subscribe({
        next: () => {
          this.saving.set('');
          this.message.set(`Decision recorded: ${outcome.toLowerCase()}.`);
          this.load();
        },
        error: (failure: { status?: number }) => {
          this.saving.set('');
          this.error.set(
            failure.status === 409
              ? 'This request changed or is no longer eligible. Refresh the queue.'
              : 'The decision could not be recorded.',
          );
        },
      });
  }

  grantDelegation(): void {
    if (
      !this.projectId() ||
      !/^EMP-TEST-[A-Z0-9-]+$/.test(this.delegateId()) ||
      this.durationDays() < 1 ||
      this.durationDays() > 30
    ) {
      this.delegationError.set('Enter a synthetic identity and a duration from 1 to 30 days.');
      return;
    }
    this.saving.set('delegation');
    this.delegationError.set('');
    this.api.grantDelegation(this.projectId(), this.delegateId(), this.durationDays()).subscribe({
      next: () => {
        this.saving.set('');
        this.delegateId.set('');
        this.loadDelegations();
      },
      error: (failure: { status?: number }) => {
        this.saving.set('');
        this.delegationError.set(
          failure.status === 403
            ? 'Only the assigned project approver can grant a delegation.'
            : 'The delegate must be an active member of this same project; no chained or department delegation is allowed.',
        );
      },
    });
  }

  revoke(delegation: ProjectDelegation): void {
    this.api.revokeDelegation(delegation.id).subscribe({
      next: () => this.loadDelegations(),
      error: () => this.delegationError.set('Only the delegator can revoke this delegation.'),
    });
  }

  inputValue(event: Event): string {
    return (event.target as HTMLInputElement).value;
  }

  Number(value: string): number {
    return Number(value);
  }
}
