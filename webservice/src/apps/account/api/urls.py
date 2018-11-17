from django.urls import path, include

from .views import (
    LoginAPIView,
    RegisterAPIView,
    UserRetrieveAPIView,
    UserUpdateAPIView,
    UserDeleteAPIView,
    UserChangePasswordUpdateAPIView,
    PasswordResetView,
    StudentListAPIView,
    UserListAPIView,
)

app_name = "api_accounts"

urlpatterns = [
    path('login', LoginAPIView.as_view(), name='login'),
    path('register', RegisterAPIView.as_view(), name='register'),
    path('update', UserUpdateAPIView.as_view()),
    path('delete', UserDeleteAPIView.as_view()),
    path('change/password', UserChangePasswordUpdateAPIView.as_view()),
    path('reset/password', PasswordResetView.as_view(), name='rest_password_reset'),
    path('reset/password/done', PasswordResetView.as_view(), name='rest_password_reset_confirm'),
    path('students', StudentListAPIView.as_view()),
    path('users', UserListAPIView.as_view()),
    path('<pk>', UserRetrieveAPIView.as_view()),
]
