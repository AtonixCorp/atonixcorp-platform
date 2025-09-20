from rest_framework import viewsets, filters
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from .models import Project, ProjectFeature, ProjectImage
from .serializers import (
    ProjectSerializer, ProjectListSerializer,
    ProjectFeatureSerializer, ProjectImageSerializer
)


class ProjectViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Project.objects.all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['status', 'is_featured']
    search_fields = ['name', 'overview', 'description']
    ordering_fields = ['name', 'created_at', 'updated_at']
    ordering = ['-is_featured', '-created_at']
    lookup_field = 'slug'
    
    def get_serializer_class(self):
        if self.action == 'list':
            return ProjectListSerializer
        return ProjectSerializer
    
    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Get featured projects"""
        featured_projects = self.queryset.filter(is_featured=True)
        serializer = self.get_serializer(featured_projects, many=True)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def by_status(self, request):
        """Get projects grouped by status"""
        result = {}
        for status_choice in Project._meta.get_field('status').choices:
            status_key = status_choice[0]
            projects = self.queryset.filter(status=status_key)
            result[status_key] = ProjectListSerializer(projects, many=True).data
        return Response(result)


class ProjectFeatureViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ProjectFeature.objects.all()
    serializer_class = ProjectFeatureSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['project']


class ProjectImageViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = ProjectImage.objects.all()
    serializer_class = ProjectImageSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_fields = ['project', 'is_featured']
