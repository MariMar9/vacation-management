import { HttpInterceptorFn } from '@angular/common/http';
import { inject } from '@angular/core';
import { SessionService } from './session.service';

export const syntheticIdentityInterceptor: HttpInterceptorFn = (request, next) => {
  if (!request.url.startsWith('/api/') && !request.url.startsWith('/test-simulator/')) {
    return next(request);
  }

  const identity = inject(SessionService).identity();
  return next(
    request.clone({
      setHeaders: { Authorization: `Bearer ${identity}` },
    }),
  );
};
