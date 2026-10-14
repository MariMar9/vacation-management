import { HttpClient } from '@angular/common/http';
import { inject, Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { RequestHistoryItem } from '../../core/feature-api.service';

export type VacationRequestHistoryItem = RequestHistoryItem;

@Injectable({ providedIn: 'root' })
export class RequestHistoryService {
  private readonly http = inject(HttpClient);

  getMyHistory(): Observable<VacationRequestHistoryItem[]> {
    return this.http.get<VacationRequestHistoryItem[]>('/api/requests/mine/history');
  }

  cancelRequest(requestId: string): Observable<unknown> {
    return this.http.post(`/api/requests/${requestId}/cancel`, {});
  }
}
