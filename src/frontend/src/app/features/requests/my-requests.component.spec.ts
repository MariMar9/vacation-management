import { provideHttpClient } from '@angular/common/http';
import { HttpTestingController, provideHttpClientTesting } from '@angular/common/http/testing';
import { TestBed } from '@angular/core/testing';
import { provideRouter } from '@angular/router';
import { MyRequestsComponent } from './my-requests.component';

describe('MyRequestsComponent', () => {
  let http: HttpTestingController;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [MyRequestsComponent],
      providers: [provideHttpClient(), provideHttpClientTesting(), provideRouter([])],
    }).compileComponents();
    http = TestBed.inject(HttpTestingController);
  });

  afterEach(() => http.verify());

  it('shows request history and the derived taken label', () => {
    const fixture = TestBed.createComponent(MyRequestsComponent);
    fixture.detectChanges();
    http.expectOne('/api/requests/mine/history').flush([
      {
        id: 'request-1',
        requesterId: 'EMP-TEST-001',
        departmentId: 'DEPT-TEST-001',
        projectId: 'PRJ-TEST-ALPHA',
        startDate: '2026-09-01',
        endDate: '2026-09-05',
        reason: null,
        status: 'Approved',
        createdAt: '2026-08-01T08:00:00Z',
        updatedAt: '2026-08-01T08:00:00Z',
        version: 1,
        taken: true,
      },
    ]);
    fixture.detectChanges();

    expect((fixture.nativeElement as HTMLElement).textContent).toContain('Approved');
    expect((fixture.nativeElement as HTMLElement).textContent).toContain('Taken');
  });

  it('groups pending, approved, and non-approved request outcomes', () => {
    const fixture = TestBed.createComponent(MyRequestsComponent);
    fixture.detectChanges();
    http.expectOne('/api/requests/mine/history').flush(
      [
        'PendingProjectApproval',
        'PendingDepartmentApproval',
        'Approved',
        'Rejected',
        'Cancelled',
      ].map((status, index) => ({
        id: `request-${index}`,
        requesterId: 'EMP-TEST-001',
        departmentId: 'DEPT-TEST-001',
        projectId: 'PRJ-TEST-ALPHA',
        startDate: '2026-09-01',
        endDate: '2026-09-05',
        reason: null,
        status,
        createdAt: '2026-08-01T08:00:00Z',
        updatedAt: '2026-08-01T08:00:00Z',
        version: 1,
        taken: status === 'Approved',
      })),
    );
    fixture.detectChanges();

    const element = fixture.nativeElement as HTMLElement;
    const pendingSection = element.querySelector('section[aria-labelledby="pending-heading"]');
    const approvedSection = element.querySelector('section[aria-labelledby="approved-heading"]');
    const notApprovedSection = element.querySelector(
      'section[aria-labelledby="not-approved-heading"]',
    );

    expect(pendingSection?.textContent).toContain('Pending Project Approval');
    expect(pendingSection?.textContent).toContain('Pending Department Approval');
    expect(approvedSection?.textContent).toContain('Approved');
    expect(notApprovedSection?.textContent).toContain('Rejected');
    expect(notApprovedSection?.textContent).toContain('Cancelled');
    expect(approvedSection?.textContent).not.toContain('Rejected');
    expect(notApprovedSection?.textContent).not.toContain('Approved');
  });

  it('shows the empty state when the requester has no history', () => {
    const fixture = TestBed.createComponent(MyRequestsComponent);
    fixture.detectChanges();
    http.expectOne('/api/requests/mine/history').flush([]);
    fixture.detectChanges();

    expect((fixture.nativeElement as HTMLElement).textContent).toContain('No requests to show');
  });

  it('shows an error and retry action when history cannot be loaded', () => {
    const fixture = TestBed.createComponent(MyRequestsComponent);
    fixture.detectChanges();
    http.expectOne('/api/requests/mine/history').flush('Unavailable', {
      status: 500,
      statusText: 'Server Error',
    });
    fixture.detectChanges();

    expect((fixture.nativeElement as HTMLElement).textContent).toContain(
      'Request history unavailable',
    );
    expect((fixture.nativeElement as HTMLElement).querySelector('button')?.textContent).toContain(
      'Retry',
    );
  });
});
