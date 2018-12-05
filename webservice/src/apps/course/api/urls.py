from django.urls import path, include

from .views import (
    CourseCreateAPIView,
    CourseListAPIView,
    CourseDeleteAPIView,
    CourseUpdateAPIView,
    CourseRetrieveAPIView,
    CourseOwnerListAPIView,
    CourseStudentOwnListAPIView,
)

app_name = "api_courses"

urlpatterns = [
    path('', CourseListAPIView.as_view(), name='courses'),
    path('create', CourseCreateAPIView.as_view()),
    path('owner', CourseOwnerListAPIView.as_view()),
    path('participator', CourseStudentOwnListAPIView.as_view()),
    path('<pk>', CourseRetrieveAPIView.as_view()),
    path('update/<pk>', CourseUpdateAPIView.as_view()),
    path('delete/<pk>', CourseDeleteAPIView.as_view()),
]
