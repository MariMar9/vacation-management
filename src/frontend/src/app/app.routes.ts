import { Routes } from '@angular/router';
import { MyRequestsComponent } from './features/requests/my-requests.component';
import { NewRequestComponent } from './features/requests/new-request.component';
import { ApprovalsComponent } from './features/approvals/approvals.component';
import { DemandComponent } from './features/demand/demand.component';
import { NotificationsComponent } from './features/notifications/notifications.component';
import { IntegrationsComponent } from './features/integrations/integrations.component';
import { AccessComponent } from './features/access/access.component';

export const routes: Routes = [
  { path: '', pathMatch: 'full', redirectTo: 'requests' },
  { path: 'requests/new', component: NewRequestComponent },
  { path: 'requests', component: MyRequestsComponent, pathMatch: 'full' },
  { path: 'approvals', component: ApprovalsComponent },
  { path: 'demand', component: DemandComponent },
  { path: 'notifications', component: NotificationsComponent },
  { path: 'integrations', component: IntegrationsComponent },
  { path: 'access', component: AccessComponent },
  { path: '**', redirectTo: 'requests' },
];
