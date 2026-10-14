import { Component, OnInit, inject } from '@angular/core';
import { RouterLink, RouterLinkActive, RouterOutlet } from '@angular/router';
import { SYNTHETIC_IDENTITIES, SessionService } from './core/session.service';

@Component({
  selector: 'app-root',
  imports: [RouterLink, RouterLinkActive, RouterOutlet],
  template: `
    <main class="workspace">
      <header class="masthead">
        <div class="brand">
          <p class="scope" data-testid="workspace-scope">TEST WORKSPACE</p>
          <h1>Vacation Management</h1>
          <p class="subtitle">Synthetic-data feature workbench</p>
        </div>
        <label class="identity-picker">
          <span>Test identity</span>
          <select [value]="session.identity()" (change)="selectIdentity($event)">
            @for (identity of identities; track identity) {
              <option [value]="identity">{{ identity }}</option>
            }
          </select>
          @if (session.profile(); as profile) {
            <small>{{ profile.roles.join(' / ') }}</small>
          } @else if (session.loading()) {
            <small>Loading access profile...</small>
          } @else if (session.error()) {
            <small class="identity-error">API profile unavailable</small>
          }
        </label>
      </header>
      <nav class="primary-nav" aria-label="Feature navigation">
        <a
          routerLink="/requests"
          routerLinkActive="active"
          [routerLinkActiveOptions]="{ exact: true }"
          >Requests</a
        >
        <a routerLink="/approvals" routerLinkActive="active">Approvals</a>
        <a routerLink="/demand" routerLinkActive="active">Demand</a>
        <a routerLink="/notifications" routerLinkActive="active">Notifications</a>
        <a routerLink="/integrations" routerLinkActive="active">Data simulators</a>
        <a routerLink="/access" routerLinkActive="active">Access</a>
      </nav>
      <section class="content">
        <router-outlet />
      </section>
      <footer>Test scope only <span aria-hidden="true">/</span> External systems simulated</footer>
    </main>
  `,
  styles: [
    `
      :host {
        display: block;
        min-height: 100vh;
        color: #19333b;
        background: #f4f7f3;
        font-family: 'Trebuchet MS', sans-serif;
      }

      .workspace {
        width: min(100% - 32px, 1040px);
        min-height: 100vh;
        margin-inline: auto;
        display: grid;
        grid-template-rows: auto 1fr auto;
      }

      .masthead {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 24px;
        padding: 24px 0;
        border-bottom: 1px solid #c9d5d0;
      }
      .brand {
        min-width: 0;
      }

      .scope,
      .section-label {
        margin: 0 0 12px;
        color: #a34832;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
      }

      h1,
      h2,
      p {
        margin-top: 0;
      }
      h1 {
        margin-bottom: 8px;
        font:
          36px/1.1 Georgia,
          serif;
      }
      .subtitle {
        margin-bottom: 0;
        color: #4d6667;
      }
      .identity-picker {
        display: grid;
        gap: 5px;
        min-width: 205px;
        color: #355157;
        font-size: 12px;
        font-weight: 700;
      }
      .identity-picker select {
        min-height: 40px;
        padding: 8px 10px;
        border: 1px solid #8fa39c;
        background: #fff;
        color: #19333b;
        font: inherit;
      }
      .identity-picker small {
        color: #4d6667;
        font-weight: 400;
      }
      .identity-picker .identity-error {
        color: #a34832;
      }
      .primary-nav {
        display: flex;
        gap: 5px;
        overflow-x: auto;
        padding: 12px 0;
        border-bottom: 1px solid #c9d5d0;
      }
      .primary-nav a {
        flex: 0 0 auto;
        padding: 8px 12px;
        color: #355157;
        text-decoration: none;
      }
      .primary-nav a.active {
        background: #dce8e2;
        color: #19333b;
        font-weight: 700;
      }
      .content {
        padding-block: 34px;
      }
      h2 {
        margin-bottom: 18px;
        font:
          24px/1.2 Georgia,
          serif;
      }
      .empty-state {
        max-width: 600px;
        padding: 18px;
        border-left: 3px solid #d78652;
        background: #e8efeb;
        color: #355157;
      }
      footer {
        padding-block: 16px;
        border-top: 1px solid #c9d5d0;
        color: #4d6667;
        font-size: 12px;
      }

      @media (max-width: 600px) {
        .workspace {
          width: min(100% - 24px, 1040px);
        }
        .masthead {
          align-items: stretch;
          flex-direction: column;
          gap: 18px;
          padding-block: 20px;
        }
        h1 {
          font-size: 30px;
        }
      }
    `,
  ],
})
export class App implements OnInit {
  readonly identities = SYNTHETIC_IDENTITIES;
  readonly session = inject(SessionService);

  ngOnInit(): void {
    this.session.loadProfile();
  }

  selectIdentity(event: Event): void {
    this.session.selectIdentity((event.target as HTMLSelectElement).value);
  }
}
