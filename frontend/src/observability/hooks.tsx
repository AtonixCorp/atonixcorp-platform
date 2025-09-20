/**
 * React hooks and utilities for OpenTelemetry
 */

import { useEffect, useCallback, useRef } from 'react';
import { trace, context, SpanKind, SpanStatusCode } from '@opentelemetry/api';

// Get tracer instance
const tracer = trace.getTracer('atonixcorp-frontend', '1.0.0');

/**
 * Hook to trace React component lifecycle
 */
export function useTracing(componentName: string, props?: Record<string, any>) {
  const spanRef = useRef<any>(null);

  useEffect(() => {
    // Start span on component mount
    spanRef.current = tracer.startSpan(`Component.${componentName}.mount`, {
      kind: SpanKind.INTERNAL,
      attributes: {
        'component.name': componentName,
        'component.type': 'react',
        'component.lifecycle': 'mount',
        ...props,
      },
    });

    // Add component props as attributes (filter sensitive data)
    if (props) {
      Object.entries(props).forEach(([key, value]) => {
        if (typeof value === 'string' || typeof value === 'number' || typeof value === 'boolean') {
          spanRef.current?.setAttributes({ [`component.props.${key}`]: value });
        }
      });
    }

    return () => {
      // End span on component unmount
      if (spanRef.current) {
        spanRef.current.setAttributes({
          'component.lifecycle': 'unmount',
        });
        spanRef.current.setStatus({ code: SpanStatusCode.OK });
        spanRef.current.end();
      }
    };
  }, [componentName]);

  return {
    addEvent: useCallback((name: string, attributes?: Record<string, any>) => {
      spanRef.current?.addEvent(name, attributes);
    }, []),
    
    setAttributes: useCallback((attributes: Record<string, any>) => {
      spanRef.current?.setAttributes(attributes);
    }, []),
    
    recordException: useCallback((error: Error) => {
      spanRef.current?.recordException(error);
      spanRef.current?.setStatus({ 
        code: SpanStatusCode.ERROR, 
        message: error.message 
      });
    }, []),
  };
}

/**
 * Hook to trace API calls
 */
export function useApiTracing() {
  return useCallback(async <T>(
    operationName: string,
    apiCall: () => Promise<T>,
    attributes?: Record<string, any>
  ): Promise<T> => {
    const span = tracer.startSpan(`API.${operationName}`, {
      kind: SpanKind.CLIENT,
      attributes: {
        'api.operation': operationName,
        'api.type': 'http',
        ...attributes,
      },
    });

    return context.with(trace.setSpan(context.active(), span), async () => {
      try {
        const result = await apiCall();
        span.setStatus({ code: SpanStatusCode.OK });
        return result;
      } catch (error) {
        span.recordException(error as Error);
        span.setStatus({ 
          code: SpanStatusCode.ERROR, 
          message: (error as Error).message 
        });
        throw error;
      } finally {
        span.end();
      }
    });
  }, []);
}

/**
 * Hook to trace user interactions
 */
export function useUserInteractionTracing() {
  return useCallback((
    interactionType: string,
    target: string,
    additionalAttributes?: Record<string, any>
  ) => {
    const span = tracer.startSpan(`Interaction.${interactionType}`, {
      kind: SpanKind.INTERNAL,
      attributes: {
        'user.interaction.type': interactionType,
        'user.interaction.target': target,
        'user.interaction.timestamp': Date.now(),
        ...additionalAttributes,
      },
    });

    // End span immediately for user interactions
    span.setStatus({ code: SpanStatusCode.OK });
    span.end();
  }, []);
}

/**
 * Hook to track page views
 */
export function usePageViewTracing(pageName: string, path: string) {
  useEffect(() => {
    const span = tracer.startSpan(`PageView.${pageName}`, {
      kind: SpanKind.INTERNAL,
      attributes: {
        'page.name': pageName,
        'page.path': path,
        'page.url': window.location.href,
        'page.referrer': document.referrer,
        'page.title': document.title,
        'browser.viewport.width': window.innerWidth,
        'browser.viewport.height': window.innerHeight,
      },
    });

    // Track time on page
    const startTime = Date.now();

    return () => {
      const timeOnPage = Date.now() - startTime;
      span.setAttributes({
        'page.time_on_page_ms': timeOnPage,
      });
      span.setStatus({ code: SpanStatusCode.OK });
      span.end();
    };
  }, [pageName, path]);
}

/**
 * Hook to track form submissions
 */
export function useFormTracing(formName: string) {
  return useCallback((
    action: 'start' | 'submit' | 'error' | 'success',
    formData?: Record<string, any>,
    error?: Error
  ) => {
    const span = tracer.startSpan(`Form.${formName}.${action}`, {
      kind: SpanKind.INTERNAL,
      attributes: {
        'form.name': formName,
        'form.action': action,
        'form.field_count': formData ? Object.keys(formData).length : 0,
      },
    });

    // Add non-sensitive form field names
    if (formData && action === 'submit') {
      const fieldNames = Object.keys(formData).filter(
        key => !key.toLowerCase().includes('password') && 
               !key.toLowerCase().includes('token') &&
               !key.toLowerCase().includes('secret')
      );
      span.setAttributes({
        'form.fields': fieldNames.join(','),
      });
    }

    if (error) {
      span.recordException(error);
      span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    } else {
      span.setStatus({ code: SpanStatusCode.OK });
    }

    span.end();
  }, [formName]);
}

/**
 * Higher-order component to trace React components
 */
export function withTracing<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  componentName?: string
) {
  const TracedComponent = (props: P) => {
    const name = componentName || WrappedComponent.displayName || WrappedComponent.name;
    const { addEvent, setAttributes, recordException } = useTracing(name, props);

    try {
      return <WrappedComponent {...props} />;
    } catch (error) {
      recordException(error as Error);
      throw error;
    }
  };

  TracedComponent.displayName = `withTracing(${WrappedComponent.displayName || WrappedComponent.name})`;
  return TracedComponent;
}

/**
 * Utility function to manually create spans
 */
export function createSpan(
  name: string,
  attributes?: Record<string, any>,
  kind: SpanKind = SpanKind.INTERNAL
) {
  return tracer.startSpan(name, {
    kind,
    attributes,
  });
}

/**
 * Utility function to get current trace context
 */
export function getCurrentTraceContext() {
  const activeSpan = trace.getActiveSpan();
  if (activeSpan) {
    const spanContext = activeSpan.spanContext();
    return {
      traceId: spanContext.traceId,
      spanId: spanContext.spanId,
      traceFlags: spanContext.traceFlags,
    };
  }
  return null;
}

/**
 * Custom error boundary with tracing
 */
export class TracingErrorBoundary extends React.Component<
  React.PropsWithChildren<{ fallback?: React.ComponentType<{ error: Error }> }>,
  { hasError: boolean; error?: Error }
> {
  constructor(props: React.PropsWithChildren<{ fallback?: React.ComponentType<{ error: Error }> }>) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    // Trace the error
    const span = tracer.startSpan('Error.React.ComponentError', {
      kind: SpanKind.INTERNAL,
      attributes: {
        'error.type': error.name,
        'error.message': error.message,
        'error.stack': error.stack || '',
        'error.component_stack': errorInfo.componentStack,
      },
    });

    span.recordException(error);
    span.setStatus({ code: SpanStatusCode.ERROR, message: error.message });
    span.end();
  }

  render() {
    if (this.state.hasError) {
      if (this.props.fallback) {
        const FallbackComponent = this.props.fallback;
        return <FallbackComponent error={this.state.error!} />;
      }
      return <div>Something went wrong.</div>;
    }

    return this.props.children;
  }
}