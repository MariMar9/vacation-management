import { HttpClient, HttpParams } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';

export type RequestStatus =
  | 'PendingProjectApproval'
  | 'PendingDepartmentApproval'
  | 'Approved'
  | 'Rejected'
  | 'Cancelled';

export interface RequestHistoryItem {
  id: string;
  requesterId: string;
  departmentId: string;
  projectId: string;
  startDate: string;
  endDate: string;
  reason: string | null;
  status: RequestStatus;
  createdAt: string;
  updatedAt: string;
  version: number;
  taken: boolean;
}

export interface ReviewRequest {
  requestId: string;
  projectId: string;
  requesterId: string;
  startDate: string;
  endDate: string;
  requestStatus: RequestStatus;
  approvalLevel: 'Project' | 'Department';
  version: number;
}

export interface ProjectDelegation {
  id: string;
  projectId: string;
  delegatorId: string;
  delegateId: string;
  startsAt: string;
  expiresAt: string;
  revokedAt: string | null;
  status: 'Active' | 'Expired' | 'Revoked';
}

export interface DemandSummary {
  scopeType: 'Department' | 'Project';
  scopeId: string;
  fromDate: string;
  toDate: string;
  activeMemberCount: number;
  peopleOnApprovedVacation: number;
  demandPercentage: number | null;
  thresholdExceeded: boolean;
  capacityExceeded: boolean;
  dataAsOf: string;
  stale: boolean;
}

export interface CapacityLimitInput {
  scopeType: 'Department' | 'Project';
  scopeId: string;
  periodStart: string;
  periodEnd: string;
  maxConcurrentPeople: number;
}

export interface CapacityLimit extends CapacityLimitInput {
  id: string;
  updatedBy: string;
  updatedAt: string;
}

export interface NotificationRecord {
  id: string;
  eventKey: string;
  requestId: string;
  eventType: string;
  recipientId: string;
  occurredAt: string;
  payload: { status: string; link: string };
  deliveryStatus: string;
  attemptCount: number;
  createdAt: string;
}

export interface OrganizationSnapshot {
  snapshotVersion: string;
  generatedAt: string;
  department: { departmentId: string; name: string };
  employees: { employeeId: string; active: boolean }[];
  projects: { projectId: string; departmentId: string }[];
  memberships: { employeeId: string; projectId: string }[];
  approverAssignments: { scopeType: string; scopeId: string; approverId: string; role: string }[];
}

export interface SnapshotStatus {
  snapshotVersion: string;
  generatedAt: string;
  stale: boolean;
  validationErrors: string[];
}

export interface VacationExportRecord {
  requestId: string;
  requestVersion: number;
  idempotencyKey: string;
  status: string;
  attemptCount: number;
  createdAt: string;
  lastAttemptAt: string | null;
}

@Injectable({ providedIn: 'root' })
export class FeatureApiService {
  private readonly http = inject(HttpClient);

  submitRequest(command: {
    projectId: string;
    startDate: string;
    endDate: string;
    reason: string | null;
  }): Observable<RequestHistoryItem> {
    return this.http.post<RequestHistoryItem>('/api/requests', command);
  }

  cancelRequest(requestId: string): Observable<RequestHistoryItem> {
    return this.http.post<RequestHistoryItem>(`/api/requests/${requestId}/cancel`, {});
  }

  listProjectRequests(projectId: string): Observable<ReviewRequest[]> {
    const params = new HttpParams()
      .set('projectId', projectId)
      .set('status', 'PendingProjectApproval');
    return this.http.get<ReviewRequest[]>('/api/review/project-requests', { params });
  }

  listDepartmentRequests(): Observable<ReviewRequest[]> {
    return this.http.get<ReviewRequest[]>('/api/review/department-requests');
  }

  decideRequest(
    request: ReviewRequest,
    level: 'project' | 'department',
    outcome: 'Approved' | 'Rejected',
    reason: string | null,
  ): Observable<unknown> {
    const path = `/api/requests/${request.requestId}/decisions/${level}`;
    const command = { outcome, reason, expectedRequestVersion: request.version };
    return this.http.post(path, command);
  }

  listDelegations(projectId: string): Observable<ProjectDelegation[]> {
    return this.http.get<ProjectDelegation[]>(`/api/projects/${projectId}/delegations`);
  }

  grantDelegation(
    projectId: string,
    delegateId: string,
    durationDays: number,
  ): Observable<ProjectDelegation> {
    return this.http.post<ProjectDelegation>(`/api/projects/${projectId}/delegations`, {
      delegateId,
      durationDays,
    });
  }

  revokeDelegation(delegationId: string): Observable<void> {
    return this.http.delete<void>(`/api/delegations/${delegationId}`);
  }

  getDemand(
    scopeType: string,
    scopeId: string,
    fromDate: string,
    toDate: string,
  ): Observable<DemandSummary> {
    const params = new HttpParams()
      .set('scopeType', scopeType)
      .set('scopeId', scopeId)
      .set('fromDate', fromDate)
      .set('toDate', toDate);
    return this.http.get<DemandSummary>('/api/demand/summary', { params });
  }

  listCapacityLimits(scopeType: string, scopeId: string): Observable<CapacityLimit[]> {
    const params = new HttpParams().set('scopeType', scopeType).set('scopeId', scopeId);
    return this.http.get<CapacityLimit[]>('/api/capacity-limits', { params });
  }

  saveCapacityLimit(input: CapacityLimitInput): Observable<CapacityLimit> {
    return this.http.put<CapacityLimit>('/api/capacity-limits', input);
  }

  listNotifications(): Observable<NotificationRecord[]> {
    return this.http.get<NotificationRecord[]>('/test-simulator/notifications');
  }

  evaluateEscalations(): Observable<{ queuedCount: number }> {
    return this.http.post<{ queuedCount: number }>(
      '/test-simulator/notifications/evaluate-escalations',
      {},
    );
  }

  importSnapshot(snapshot: OrganizationSnapshot): Observable<void> {
    return this.http.post<void>('/test-simulator/organization/snapshots', snapshot);
  }

  getSnapshotStatus(): Observable<SnapshotStatus> {
    return this.http.get<SnapshotStatus>('/test-simulator/organization/snapshots/current');
  }

  listVacationExports(): Observable<VacationExportRecord[]> {
    return this.http.get<VacationExportRecord[]>('/test-simulator/vacation-exports');
  }

  evaluateVacationExports(
    simulateFailure: boolean,
  ): Observable<{ processedCount: number; simulateFailure: boolean }> {
    return this.http.post<{ processedCount: number; simulateFailure: boolean }>(
      '/test-simulator/vacation-exports/evaluate',
      { simulateFailure },
    );
  }
}
