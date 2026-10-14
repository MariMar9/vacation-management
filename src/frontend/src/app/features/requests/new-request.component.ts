import { Component, effect, inject, signal } from '@angular/core';
import { FormControl, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { FeatureApiService } from '../../core/feature-api.service';
import { SessionService } from '../../core/session.service';

@Component({
  selector: 'app-new-request',
  standalone: true,
  imports: [ReactiveFormsModule, RouterLink],
  template: `
    <section class="feature-page" aria-labelledby="new-request-title">
      <header class="page-heading">
        <div>
          <p class="eyebrow">Requester workflow</p>
          <h2 id="new-request-title">New vacation request</h2>
        </div>
        <a class="quiet-link" routerLink="/requests">Back to requests</a>
      </header>

      @if (created()) {
        <section class="notice success" role="status">
          <h3>Request submitted</h3>
          <p>Your request is now awaiting project approval.</p>
          <a routerLink="/requests">View request history</a>
        </section>
      } @else {
        <form class="form-panel" [formGroup]="form" (ngSubmit)="submit()">
          <div class="form-grid">
            <label class="field">
              <span>Project</span>
              <select formControlName="projectId" required>
                <option value="" disabled>Select a project</option>
                @for (projectId of session.profile()?.membershipProjectIds ?? []; track projectId) {
                  <option [value]="projectId">{{ projectId }}</option>
                }
              </select>
            </label>
            <label class="field">
              <span>Start date</span>
              <input type="date" [min]="today" formControlName="startDate" required />
            </label>
            <label class="field">
              <span>End date</span>
              <input
                type="date"
                [min]="form.controls.startDate.value || today"
                formControlName="endDate"
                required
              />
            </label>
            <label class="field field-wide">
              <span>Reason <small>Optional, up to 500 characters</small></span>
              <textarea rows="3" maxlength="500" formControlName="reason"></textarea>
            </label>
          </div>
          @if (error()) {
            <p class="notice error" role="alert">{{ error() }}</p>
          }
          <div class="form-actions">
            <button class="button primary" type="submit" [disabled]="form.invalid || submitting()">
              {{ submitting() ? 'Submitting...' : 'Submit request' }}
            </button>
            <p>
              Dates are inclusive calendar days. Requests require project and department approval.
            </p>
          </div>
        </form>
      }
    </section>
  `,
})
export class NewRequestComponent {
  private readonly api = inject(FeatureApiService);
  readonly session = inject(SessionService);
  readonly submitting = signal(false);
  readonly created = signal(false);
  readonly error = signal('');
  readonly today = new Intl.DateTimeFormat('en-CA', { timeZone: 'Europe/Madrid' }).format(
    new Date(),
  );
  readonly form = new FormGroup({
    projectId: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    startDate: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    endDate: new FormControl('', { nonNullable: true, validators: [Validators.required] }),
    reason: new FormControl('', { nonNullable: true, validators: [Validators.maxLength(500)] }),
  });

  constructor() {
    effect(() => {
      const projects = this.session.profile()?.membershipProjectIds ?? [];
      const selectedProject = this.form.controls.projectId.value;
      if (!projects.includes(selectedProject)) {
        this.form.controls.projectId.setValue(projects[0] ?? '');
      }
    });
  }

  submit(): void {
    if (this.form.invalid || this.submitting()) {
      this.form.markAllAsTouched();
      return;
    }

    const command = this.form.getRawValue();
    this.submitting.set(true);
    this.error.set('');
    this.api.submitRequest({ ...command, reason: command.reason || null }).subscribe({
      next: () => {
        this.created.set(true);
        this.submitting.set(false);
      },
      error: (failure: { status?: number }) => {
        this.error.set(
          failure.status === 400
            ? 'Check the dates and request details.'
            : failure.status === 403
              ? 'You are not an active member of that project.'
              : failure.status === 409
                ? 'The dates overlap another active request or the organization setup needs attention.'
                : 'The request could not be submitted. Check the test API connection.',
        );
        this.submitting.set(false);
      },
    });
  }
}
