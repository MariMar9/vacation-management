import { Component, inject, OnInit } from '@angular/core';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-access',
  standalone: true,
  template: `
    <section class="feature-page" aria-labelledby="access-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">F-006 / local test access</p>
          <h2 id="access-title">Entry and access profile</h2>
        </div>
      </header>
      <p class="notice">
        This isolated workspace uses pre-provisioned synthetic identities. It has no public signup,
        password collection, or live Entra connection.
      </p>
      @if (session.loading()) {
        <p class="notice" role="status">Loading access profile...</p>
      } @else if (session.error()) {
        <p class="notice error" role="alert">
          No access profile is available. Start the local API and retry.
        </p>
      } @else if (session.profile(); as profile) {
        <dl class="profile-grid">
          <div>
            <dt>Identity</dt>
            <dd>{{ profile.subjectId }}</dd>
          </div>
          <div>
            <dt>Active</dt>
            <dd>{{ profile.active ? 'Yes' : 'No' }}</dd>
          </div>
          <div>
            <dt>Department scope</dt>
            <dd>{{ profile.departmentId }}</dd>
          </div>
          <div>
            <dt>Roles</dt>
            <dd>{{ profile.roles.join(', ') }}</dd>
          </div>
          <div>
            <dt>Project scopes</dt>
            <dd>{{ profile.projectIds.length ? profile.projectIds.join(', ') : 'None' }}</dd>
          </div>
          <div>
            <dt>Project memberships</dt>
            <dd>
              {{
                profile.membershipProjectIds.length
                  ? profile.membershipProjectIds.join(', ')
                  : 'None'
              }}
            </dd>
          </div>
          <div class="profile-wide">
            <dt>Projects where this identity may delegate</dt>
            <dd>
              {{
                profile.delegatableProjectIds.length
                  ? profile.delegatableProjectIds.join(', ')
                  : 'None'
              }}
            </dd>
          </div>
        </dl>
        <section class="subsection" aria-labelledby="capabilities-title">
          <div class="subsection-heading">
            <div>
              <p class="eyebrow">Server-side authorization</p>
              <h3 id="capabilities-title">Available actions</h3>
            </div>
          </div>
          <ul class="capability-list">
            @for (capability of capabilities; track capability.name) {
              <li>
                <span>{{ capability.name }}</span
                ><span>{{
                  allowed(profile.roles, capability.roles)
                    ? 'Available for this profile'
                    : 'Not assigned'
                }}</span>
              </li>
            }
          </ul>
        </section>
        <p class="muted">
          Changing the test identity in the header refreshes this profile. Cross-scope access and
          self-approval remain denied by the API.
        </p>
      }
      <button class="button quiet" type="button" (click)="session.loadProfile()">
        Refresh profile
      </button>
    </section>
  `,
})
export class AccessComponent implements OnInit {
  readonly session = inject(SessionService);
  readonly capabilities = [
    { name: 'Create and cancel own requests', roles: ['Requester'] },
    {
      name: 'Review project requests and manage same-project delegations',
      roles: ['ProjectApprover'],
    },
    { name: 'Decide at department level and set advisory limits', roles: ['DepartmentApprover'] },
    {
      name: 'Read demand in an assigned direct scope',
      roles: ['ProjectApprover', 'DepartmentApprover'],
    },
  ];

  ngOnInit(): void {
    if (!this.session.profile()) this.session.loadProfile();
  }

  allowed(userRoles: string[], requiredRoles: string[]): boolean {
    return requiredRoles.some((role) => userRoles.includes(role));
  }
}
