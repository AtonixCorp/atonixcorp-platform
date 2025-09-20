"""
URL configuration for atonixcorp project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.2/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from rest_framework.decorators import api_view
from rest_framework.response import Response
from .auth_views import LoginView, SignupView, LogoutView, MeView
from core.health import health_check


@api_view(['GET'])
def api_root(request):
    """API root endpoint providing available endpoints"""
    return Response({
        'message': 'Welcome to AtonixCorp Platform API',
        'version': '1.0',
        'endpoints': {
            'projects': '/api/projects/',
            'teams': '/api/teams/',
            'focus_areas': '/api/focus-areas/',
            'resources': '/api/resources/',
            'contact': '/api/contact/',
            'dashboard': '/api/dashboard/',
            'zookeeper': '/api/zookeeper/',
            'auth': {
                'login': '/api/auth/login/',
                'signup': '/api/auth/signup/',
                'logout': '/api/auth/logout/',
                'me': '/api/auth/me/',
            },
            'admin': '/admin/',
        }
    })


urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', api_root, name='api-root'),
    
    # Health check endpoint
    path('health/', health_check, name='health-check'),
    
    # Authentication endpoints
    path('api/auth/login/', LoginView.as_view(), name='login'),
    path('api/auth/signup/', SignupView.as_view(), name='signup'),
    path('api/auth/logout/', LogoutView.as_view(), name='logout'),
    path('api/auth/me/', MeView.as_view(), name='me'),
    
    # App endpoints
    path('', include('projects.urls')),
    path('', include('teams.urls')),
    path('', include('focus_areas.urls')),
    path('', include('resources.urls')),
    path('', include('contact.urls')),
    path('api/dashboard/', include('dashboard.urls')),
    
    # Zookeeper endpoints
    path('api/zookeeper/', include('core.zookeeper_urls')),
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
