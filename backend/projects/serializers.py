from rest_framework import serializers
from .models import Project, ProjectFeature, ProjectImage


class ProjectFeatureSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProjectFeature
        fields = ['id', 'title', 'description', 'icon', 'order']


class ProjectImageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProjectImage
        fields = ['id', 'image', 'caption', 'is_featured', 'order']


class ProjectSerializer(serializers.ModelSerializer):
    features = ProjectFeatureSerializer(many=True, read_only=True)
    images = ProjectImageSerializer(many=True, read_only=True)
    
    class Meta:
        model = Project
        fields = [
            'id', 'name', 'slug', 'overview', 'description', 'image',
            'technologies', 'status', 'website_url', 'github_url',
            'documentation_url', 'is_featured', 'created_at', 'updated_at',
            'features', 'images'
        ]


class ProjectListSerializer(serializers.ModelSerializer):
    """Simplified serializer for project lists"""
    class Meta:
        model = Project
        fields = [
            'id', 'name', 'slug', 'overview', 'image', 'technologies',
            'status', 'is_featured', 'created_at'
        ]