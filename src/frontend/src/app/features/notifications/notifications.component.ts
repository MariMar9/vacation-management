import { DatePipe } from '@angular/common';
import { Component, inject, OnInit, signal } from '@angular/core';
import { FeatureApiService, NotificationRecord } from '../../core/feature-api.service';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-notifications',
  standalone: true,
  imports: [DatePipe],
  template: `
    <section class="feature-page" aria-labelledby="notifications-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">F-004 / local simulator</p>
          <h2 id="notifications-title">Notification outbox</h2>
        </div>
        <div class="button-row">
          @if (canEvaluate()) {
            <button
              class="button primary"
              type="button"
              [disabled]="evaluating()"
              (click)="evaluate()"
            >
              {{ evaluating() ? 'Evaluating...' : 'Evaluate reminders' }}
            </button>
          }
          <button class="button quiet" type="button" (click)="load()">Refresh</button>
        </div>
      </header>
      <p class="notice">
        This page inspects simulated notification records only. No email or Teams message is sent.
      </p>
      @if (message()) {
        <p class="notice success" role="status">{{ message() }}</p>
      }
      @if (error()) {
        <p class="notice error" role="alert">{{ error() }}</p>
      }
      @if (loading()) {
        <p class="notice" role="status">Loading notification records...</p>
      } @else if (records().length === 0) {
        <p class="notice">No notifications have been queued for {{ session.identity() }}.</p>
      } @else {
        <div class="table-scroll">
          <table>
            <thead>
              <tr>
                <th>Created</th>
                <th>Event</th>
                <th>Request</th>
                <th>Status</th>
                <th>Attempts</th>
              </tr>
            </thead>
            <tbody>
              @for (record of records(); track record.id) {
                <tr>
                  <td>{{ record.createdAt | date: 'medium' }}</td>
                  <td>{{ record.eventType }}</td>
                  <td>
                    <a [href]="record.payload.link">{{ record.requestId }}</a>
                  </td>
                  <td>{{ record.deliveryStatus }}</td>
                  <td>{{ record.attemptCount }}</td>
                </tr>
              }
            </tbody>
          </table>
        </div>
      }
    </section>
  `,
})
export class NotificationsComponent implements OnInit {
  private readonly api = inject(FeatureApiService);
  readonly session = inject(SessionService);
  readonly records = signal<NotificationRecord[]>([]);
  readonly loading = signal(false);
  readonly evaluating = signal(false);
  readonly error = signal('');
  readonly message = signal('');

  ngOnInit(): void {
    this.load();
  }
  canEvaluate(): boolean {
    return this.session.profile()?.roles.includes('DepartmentApprover') ?? false;
  }

  load(): void {
    this.loading.set(true);
    this.error.set('');
    this.api.listNotifications().subscribe({
      next: (records) => {
        this.records.set(records);
        this.loading.set(false);
      },
      error: () => {
        this.records.set([]);
        this.loading.set(false);
        this.error.set('Notifications are visible only to their recipient.');
      },
    });
  }

  evaluate(): void {
    this.evaluating.set(true);
    this.message.set('');
    this.api.evaluateEscalations().subscribe({
      next: (result) => {
        this.evaluating.set(false);
        this.message.set(`${result.queuedCount} reminder or escalation event(s) queued.`);
        this.load();
      },
      error: () => {
        this.evaluating.set(false);
        this.error.set('Only the department test operator can evaluate reminders.');
      },
    });
  }
}
