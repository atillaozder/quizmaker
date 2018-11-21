from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from course.models import Course

from quiz.models import Quiz
from quiz.api.serializers import QuizSerializer
from account.api.serializers import StudentSerializer

User = get_user_model()

class CourseSerializer(serializers.ModelSerializer):
    students = StudentSerializer(many=True)
    instructor_name = serializers.SerializerMethodField()

    class Meta:
        model = Course
        fields = (
            'id',
            'owner',
            'instructor_name',
            'name',
            'students',
        )

    def get_instructor_name(self, instance):
        return instance.owner.user.username

    def to_representation(self, instance):
        data = super(CourseSerializer, self).to_representation(instance)
        queryset = Quiz.objects.filter(course__id=instance.id).all()
        serializer = QuizSerializer(instance=queryset, many=True, context={'request': self.context['request']})
        data['quizzes'] = serializer.data
        return data

class CourseCreateUpdateSerializer(serializers.ModelSerializer):

    class Meta:
        model = Course
        fields = (
            'name',
            'students',
        )
