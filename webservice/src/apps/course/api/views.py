from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    UpdateAPIView,
    GenericAPIView,
    DestroyAPIView,
    CreateAPIView,
)

from course.models import Course
from course.api.serializers import (
    CourseSerializer,
    CourseCreateUpdateSerializer,
)

User = get_user_model()

class CourseRetrieveAPIView(RetrieveAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

class CourseOwnerListAPIView(ListAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    def get(self, request, *args, **kwargs):
        if request.user.user_type == 'D':
            return Response(
                {'message': _('Courses is not available for this user type.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        elif request.user.user_type == 'I' and not request.user.instructor.is_approved:
            return Response(
                {'message': _('You should be approved by any admin to see the result.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return super(CourseOwnerListAPIView, self).get(request, *args, **kwargs)

    def get_queryset(self):
        if self.request.user.is_instructor:
            return Course.objects.filter(owner=self.request.user.instructor).all()

class CourseStudentOwnListAPIView(ListAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    def get(self, request, *args, **kwargs):
        if request.user.user_type != 'S':
            return Response(
                {'message': _('Courses is not available for this user type.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return super(CourseStudentOwnListAPIView, self).get(request, *args, **kwargs)

    def get_queryset(self):
        if self.request.user.is_student:
            return Course.objects.filter(students__user_id=self.request.user.id).all()

class CourseListAPIView(ListAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    def get(self, request, *args, **kwargs):
        if request.user.user_type == 'D':
            return Response(
                {'message': _('Courses is not available for this user type.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        elif request.user.user_type == 'I' and not request.user.instructor.is_approved:
            return Response(
                {'message': _('You should be approved by any admin to see the result.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return super(CourseListAPIView, self).get(request, *args, **kwargs)

class CourseDeleteAPIView(DestroyAPIView):
    queryset = Course.objects.all()

class CourseUpdateAPIView(UpdateAPIView):
    queryset = Course.objects.all()
    serializer_class = CourseCreateUpdateSerializer

    def put(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)

class CourseCreateAPIView(CreateAPIView):
    serializer_class = CourseCreateUpdateSerializer

    def create(self, request, *args, **kwargs):
        if self.request.user.user_type == 'I' and self.request.user.instructor.is_approved:
            return super(CourseCreateAPIView, self).create(request, *args, **kwargs)
        return Response({'message': _('Only instructors can create a course.')}, status=status.HTTP_400_BAD_REQUEST)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user.instructor)
