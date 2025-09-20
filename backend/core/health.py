"""
Health check views for monitoring application status
"""
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.db import connection
import redis
from django.conf import settings
import logging

logger = logging.getLogger(__name__)

@csrf_exempt
def health_check(request):
    """
    Health check endpoint for load balancers and monitoring
    """
    status = {"status": "healthy", "checks": {}}
    overall_healthy = True
    
    # Database check
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        status["checks"]["database"] = "healthy"
    except Exception as e:
        status["checks"]["database"] = f"unhealthy: {str(e)}"
        overall_healthy = False
        logger.error(f"Database health check failed: {e}")
    
    # Redis check
    try:
        redis_url = getattr(settings, 'REDIS_URL', 'redis://localhost:6379/0')
        r = redis.from_url(redis_url)
        r.ping()
        status["checks"]["redis"] = "healthy"
    except Exception as e:
        status["checks"]["redis"] = f"unhealthy: {str(e)}"
        overall_healthy = False
        logger.error(f"Redis health check failed: {e}")
    
    # Zookeeper check (optional)
    try:
        if hasattr(settings, 'ZOOKEEPER_HOSTS'):
            from core.zookeeper_client import get_zk_client
            zk = get_zk_client()
            # Simple check - if we can get the client, connection is working
            status["checks"]["zookeeper"] = "healthy"
    except Exception as e:
        status["checks"]["zookeeper"] = f"unhealthy: {str(e)}"
        # Don't mark overall as unhealthy for optional services
        logger.warning(f"Zookeeper health check failed: {e}")
    
    # Kafka check (optional)
    try:
        if hasattr(settings, 'KAFKA_BOOTSTRAP_SERVERS'):
            from core.kafka_client import get_kafka_client
            kafka = get_kafka_client()
            # Simple check - if we can get the client, connection is working
            status["checks"]["kafka"] = "healthy"
    except Exception as e:
        status["checks"]["kafka"] = f"unhealthy: {str(e)}"
        # Don't mark overall as unhealthy for optional services
        logger.warning(f"Kafka health check failed: {e}")
    
    # RabbitMQ check (optional)
    try:
        if hasattr(settings, 'RABBITMQ_URL'):
            from core.rabbitmq_client import get_rabbitmq_client
            rabbitmq = get_rabbitmq_client()
            # Simple check - if we can get the client, connection is working
            status["checks"]["rabbitmq"] = "healthy"
    except Exception as e:
        status["checks"]["rabbitmq"] = f"unhealthy: {str(e)}"
        # Don't mark overall as unhealthy for optional services
        logger.warning(f"RabbitMQ health check failed: {e}")
    
    if not overall_healthy:
        status["status"] = "unhealthy"
        return JsonResponse(status, status=503)
    
    return JsonResponse(status, status=200)