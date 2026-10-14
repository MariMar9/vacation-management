import { Component, computed, inject, OnInit, signal } from '@angular/core';
import { RouterLink } from '@angular/router';
import { RequestHistoryService, VacationRequestHistoryItem } from './request-history.service';

@Component({
  selector: 'app-my-requests',
  standalone: true,
  imports: [RouterLink],
  template: `
    <main class="requests" aria-labelledby="requests-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">Requester view</p>
          <h1 id="requests-title">My vacation requests</h1>
        </div>
        <a class="new-request" routerLink="/requests/new">New request</a>
      </header>

      @if (loading()) {
        <p class="message" role="status" aria-live="polite">Loading your request history...</p>
      } @else if (error()) {
        <section class="message error" role="alert">
          <h2>Request history unavailable</h2>
          <p>We could not load your requests. Try again.</p>
          <button type="button" (click)="loadHistory()">Retry</button>
        </section>
      } @else if (requests().length === 0) {
        <section class="message empty" aria-labelledby="empty-title">
          <h2 id="empty-title">No requests to show</h2>
          <p>No synthetic requests match this requester.</p>
          <a class="new-request" routerLink="/requests/new">New request</a>
        </section>
      } @else {
        <section aria-labelledby="history-title">
          <h2 id="history-title">Request history</h2>
          <div class="filter-bar" role="group" aria-label="Filter request history">
            @for (option of filters; track option) {
              <button
                type="button"
                [class.selected]="filter() === option"
                (click)="filter.set(option)"
              >
                {{ option }}
              </button>
            }
          </div>
          <div class="table-scroll">
            <table>
              <thead>
                <tr>
                  <th scope="col">Requested period</th>
                  <th scope="col">Project</th>
                  <th scope="col">Outcome</th>
                  <th scope="col">History</th>
                </tr>
              </thead>
              <tbody>
                @for (request of visibleRequests(); track request.id) {
                  <tr>
                    <td>{{ request.startDate }} to {{ request.endDate }}</td>
                    <td>{{ request.projectId }}</td>
                    <td>{{ statusLabel(request.status) }}</td>
                    <td>
                      {{
                        request.taken ? 'Taken' : request.status === 'Approved' ? 'Not taken' : '—'
                      }}
                      @if (request.status === 'PendingProjectApproval') {
                        <button
                          class="table-action"
                          type="button"
                          [disabled]="cancelling() === request.id"
                          (click)="cancel(request.id)"
                        >
                          {{ cancelling() === request.id ? 'Cancelling...' : 'Cancel' }}
                        </button>
                      }
                    </td>
                  </tr>
                }
              </tbody>
            </table>
          </div>
          <p class="taken-note">
            Taken means approved with an end date before today's Europe/Madrid date.
          </p>
        </section>
      }
      @if (actionError()) {
        <p class="message error" role="alert">{{ actionError() }}</p>
      }
    </main>
  `,
  styles: [
    `
      .requests {
        max-width: 900px;
        margin: 0 auto;
        padding: 32px 20px;
        color: #19333b;
      }
      .page-heading {
        display: flex;
        align-items: end;
        justify-content: space-between;
        gap: 20px;
        margin-bottom: 28px;
      }
      .eyebrow {
        margin: 0 0 8px;
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
        margin-bottom: 0;
        font:
          30px/1.15 Georgia,
          serif;
      }
      h2 {
        font:
          22px/1.2 Georgia,
          serif;
      }
      .new-request,
      button {
        display: inline-block;
        padding: 10px 14px;
        border: 1px solid #526a69;
        background: #fff;
        color: #19333b;
        font: inherit;
        text-decoration: none;
        cursor: pointer;
      }
      .table-scroll {
        overflow-x: auto;
        border: 1px solid #c9d5d0;
        background: #fff;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        text-align: left;
      }
      th,
      td {
        padding: 13px 14px;
        border-bottom: 1px solid #dbe3df;
        white-space: nowrap;
      }
      th {
        background: #e8efeb;
        font-size: 13px;
      }
      tr:last-child td {
        border-bottom: 0;
      }
      .taken-note {
        margin-top: 18px;
        padding-left: 12px;
        border-left: 3px solid #d78652;
        color: #4d6667;
        font-size: 14px;
      }
      .message {
        padding: 22px;
        border: 1px solid #c9d5d0;
        background: #fff;
      }
      .error {
        border-color: #a34832;
      }
      .filter-bar {
        display: flex;
        gap: 4px;
        margin: 0 0 14px;
      }
      .filter-bar button {
        padding: 8px 12px;
        border: 1px solid #a9bab3;
        background: transparent;
        color: #355157;
        font: inherit;
        cursor: pointer;
      }
      .filter-bar button.selected {
        background: #19333b;
        color: #fff;
      }
      .table-action {
        margin-left: 10px;
        border: 0;
        background: transparent;
        color: #a34832;
        font: inherit;
        text-decoration: underline;
        cursor: pointer;
      }
      @media (max-width: 600px) {
        .requests {
          padding: 24px 12px;
        }
        .page-heading {
          align-items: start;
          flex-direction: column;
        }
        h1 {
          font-size: 27px;
        }
      }
    `,
  ],
})
export class MyRequestsComponent implements OnInit {
  private readonly historyService = inject(RequestHistoryService);
  readonly requests = signal<VacationRequestHistoryItem[]>([]);
  readonly loading = signal(true);
  readonly error = signal(false);
  readonly actionError = signal('');
  readonly cancelling = signal('');
  readonly filters = ['All', 'Pending', 'Approved', 'Not approved'] as const;
  readonly filter = signal<(typeof this.filters)[number]>('All');
  readonly visibleRequests = computed(() => {
    const selected = this.filter();
    return this.requests().filter((request) => {
      if (selected === 'Pending') return request.status.startsWith('Pending');
      if (selected === 'Approved') return request.status === 'Approved';
      if (selected === 'Not approved')
        return request.status === 'Rejected' || request.status === 'Cancelled';
      return true;
    });
  });

  ngOnInit(): void {
    this.loadHistory();
  }

  loadHistory(): void {
    this.loading.set(true);
    this.error.set(false);
    this.historyService.getMyHistory().subscribe({
      next: (requests) => {
        this.requests.set(requests);
        this.loading.set(false);
      },
      error: () => {
        this.error.set(true);
        this.loading.set(false);
      },
    });
  }

  cancel(requestId: string): void {
    this.cancelling.set(requestId);
    this.actionError.set('');
    this.historyService.cancelRequest(requestId).subscribe({
      next: () => {
        this.cancelling.set('');
        this.loadHistory();
      },
      error: (failure: { status?: number }) => {
        this.cancelling.set('');
        this.actionError.set(
          failure.status === 404
            ? 'This request is not available to the selected identity.'
            : 'The request can no longer be cancelled. Refresh the history and try again.',
        );
      },
    });
  }

  statusLabel(status: VacationRequestHistoryItem['status']): string {
    return status.replace(/([a-z])([A-Z])/g, '$1 $2');
  }
}
