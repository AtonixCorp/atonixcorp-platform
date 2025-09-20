/**
 * OpenTelemetry configuration for React frontend
 */

import { WebSDK } from '@opentelemetry/sdk-web';
import { Resource } from '@opentelemetry/resources';
import { SemanticResourceAttributes } from '@opentelemetry/semantic-conventions';
import { BatchSpanProcessor, ConsoleSpanExporter } from '@opentelemetry/sdk-web';
import { getWebAutoInstrumentations } from '@opentelemetry/auto-instrumentations-web';
import { JaegerExporter } from '@opentelemetry/exporter-jaeger';
import { OTLPTraceExporter } from '@opentelemetry/exporter-otlp-http';

// Configuration
const config = {
  serviceName: process.env.REACT_APP_OTEL_SERVICE_NAME || 'atonixcorp-frontend',
  serviceVersion: process.env.REACT_APP_OTEL_SERVICE_VERSION || '1.0.0',
  environment: process.env.REACT_APP_ENVIRONMENT || 'development',
  jaegerEndpoint: process.env.REACT_APP_JAEGER_ENDPOINT || 'http://localhost:14268/api/traces',
  otlpEndpoint: process.env.REACT_APP_OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318/v1/traces',
  enableConsole: process.env.REACT_APP_OTEL_ENABLE_CONSOLE === 'true',
  enableJaeger: process.env.REACT_APP_OTEL_ENABLE_JAEGER !== 'false',
  enableOtlp: process.env.REACT_APP_OTEL_ENABLE_OTLP === 'true',
  enabled: process.env.REACT_APP_OTEL_ENABLED !== 'false',
};

// Create resource
const resource = new Resource({
  [SemanticResourceAttributes.SERVICE_NAME]: config.serviceName,
  [SemanticResourceAttributes.SERVICE_VERSION]: config.serviceVersion,
  [SemanticResourceAttributes.DEPLOYMENT_ENVIRONMENT]: config.environment,
  [SemanticResourceAttributes.SERVICE_NAMESPACE]: 'atonixcorp',
  'browser.user_agent': navigator.userAgent,
  'browser.language': navigator.language,
  'browser.platform': navigator.platform,
});

// Create span processors
const spanProcessors = [];

// Console exporter for development
if (config.enableConsole) {
  spanProcessors.push(new BatchSpanProcessor(new ConsoleSpanExporter()));
}

// Jaeger exporter
if (config.enableJaeger) {
  try {
    const jaegerExporter = new JaegerExporter({
      endpoint: config.jaegerEndpoint,
    });
    spanProcessors.push(new BatchSpanProcessor(jaegerExporter));
  } catch (error) {
    console.warn('Failed to setup Jaeger exporter:', error);
  }
}

// OTLP exporter
if (config.enableOtlp) {
  try {
    const otlpExporter = new OTLPTraceExporter({
      url: config.otlpEndpoint,
      headers: {},
    });
    spanProcessors.push(new BatchSpanProcessor(otlpExporter));
  } catch (error) {
    console.warn('Failed to setup OTLP exporter:', error);
  }
}

// Initialize OpenTelemetry SDK
let sdk: WebSDK | null = null;

export function initializeOpenTelemetry(): void {
  if (!config.enabled) {
    console.log('OpenTelemetry is disabled');
    return;
  }

  try {
    sdk = new WebSDK({
      resource,
      spanProcessors,
      instrumentations: [
        getWebAutoInstrumentations({
          '@opentelemetry/instrumentation-fetch': {
            propagateTraceHeaderCorsUrls: [
              /^http:\/\/localhost:8000\/.*$/,  // Django backend
              /^https:\/\/api\.atonixcorp\.com\/.*$/,  // Production API
            ],
            clearTimingResources: true,
            // Custom hooks for fetch instrumentation
            requestHook: (span, request) => {
              span.setAttributes({
                'http.request.method': request.method,
                'http.request.url': request.url,
                'atonixcorp.request.type': 'api',
              });
            },
            responseHook: (span, response) => {
              span.setAttributes({
                'http.response.status_code': response.status,
                'http.response.content_length': response.headers.get('content-length') || '',
                'atonixcorp.response.type': response.headers.get('content-type') || '',
              });
            },
          },
          '@opentelemetry/instrumentation-xml-http-request': {
            propagateTraceHeaderCorsUrls: [
              /^http:\/\/localhost:8000\/.*$/,
              /^https:\/\/api\.atonixcorp\.com\/.*$/,
            ],
          },
          '@opentelemetry/instrumentation-user-interaction': {
            enabled: true,
            eventNames: ['click', 'submit', 'keydown'],
          },
          '@opentelemetry/instrumentation-document-load': {
            enabled: true,
          },
        }),
      ],
    });

    sdk.start();
    console.log('OpenTelemetry initialized successfully');
  } catch (error) {
    console.error('Failed to initialize OpenTelemetry:', error);
  }
}

export function shutdownOpenTelemetry(): Promise<void> {
  if (sdk) {
    return sdk.shutdown();
  }
  return Promise.resolve();
}

// Export configuration for use in other modules
export { config };