from django.core.mail import send_mail
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from django.utils.decorators import method_decorator
from django.views.decorators.debug import sensitive_post_parameters

from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    UpdateAPIView,
    GenericAPIView
)

from account.models import Student
from account.api.serializers import (
    LoginSerializer,
    RegisterSerializer,
    UserSerializer,
    UserUpdateSerializer,
    ChangePasswordSerializer,
    PasswordResetSerializer,
    StudentSerializer
)

User = get_user_model()

class LoginAPIView(APIView):
    authentication_classes = ()
    permission_classes = (AllowAny,)
    serializer_class = LoginSerializer

    # to handle sensitive password_validation
    @method_decorator(sensitive_post_parameters())
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)

    def post(self, request, format='json', *args, **kwargs):
        should_open = request.GET.get("q") # to handle open deleted accounts
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            user = User.objects.get(id=serializer.data.get('id'))

            if should_open == 'open':
                user.is_active = True
                user.save()

            if not user.is_active:
                message = {
                    "error": _('Activation'),
                    "error_description": _('Account is not active. You will get this message'
                                           'if a user is delete his/her account'),
                    "error_code": 4032
                }
                return Response(message, status=status.HTTP_403_FORBIDDEN)

            if user.is_instructor:
                if not user.instructor.is_approved:
                    message = {
                        "error": _('Approved'),
                        "error_description": _('Account is not approved. You will get this message'
                                               'if a user is not approved by admin'),
                        "error_code": 4033
                    }
                    return Response(message, status=status.HTTP_403_FORBIDDEN)
            return Response(serializer.data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class RegisterAPIView(APIView):
    authentication_classes = ()
    permission_classes = (AllowAny,)
    serializer_class = RegisterSerializer

    # to handle sensitive password_validation
    @method_decorator(sensitive_post_parameters())
    def dispatch(self, request, *args, **kwargs):
        return super().dispatch(request, *args, **kwargs)

    def post(self, request, format='json', *args, **kwargs):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            data = serializer.data
            if user.user_type == 'S':
                data['student_id'] = user.student.student_id

            if user:
                return Response(data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class UserRetrieveAPIView(RetrieveAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def retrieve(self, request, *args, **kwargs):
        user = self.get_object()
        serializer = self.get_serializer(user)
        data = serializer.data

        if user.user_type == 'S':
            data['student_id'] = user.student.student_id
        elif user.user_type == 'I':
            data['is_approved'] = user.instructor.is_approved

        return Response(data)

class UserDeleteAPIView(APIView):

    def post(self, request, *args, **kwargs):
        user = request.user
        user.is_active = False
        user.save()
        return Response(status=status.HTTP_200_OK)

class UserUpdateAPIView(UpdateAPIView):
    serializer_class = UserUpdateSerializer

    def get_object(self):
        return self.request.user

    def put(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)

class UserChangePasswordUpdateAPIView(UpdateAPIView):
    serializer_class = ChangePasswordSerializer

    def get_object(self):
        return self.request.user

    def update(self, request, *args, **kwargs):
        self.object = self.get_object()
        serializer = self.get_serializer(data=request.data)

        if serializer.is_valid():
            old_password = serializer.data.get('old_password')
            new_password = serializer.data.get('new_password')
            confirm_password = serializer.data.get('confirm_password')

            if old_password == new_password:
                error_message = {'new_password': [_('The old and new password cannot be the same.')]}
                return Response(error_message, status=status.HTTP_400_BAD_REQUEST)

            if not self.object.check_password(old_password):
                error_message = {'old_password': [_('Old password is wrong.')]}
                return Response(error_message, status=status.HTTP_400_BAD_REQUEST)

            if new_password == confirm_password:
                self.object.set_password(new_password)
                self.object.save()
                return Response(status=status.HTTP_200_OK)
            else:
                error_message = {'new_password': [_('Passwords do not match.')]}
                return Response(error_message, status=status.HTTP_400_BAD_REQUEST)

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PasswordResetView(GenericAPIView):
    serializer_class = PasswordResetSerializer
    authentication_classes = ()
    permission_classes = (AllowAny,)

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        email = serializer.data.get('email')

        qs = User.objects.filter(email__iexact=email)
        if not qs.exists():
            message = {'message': _('The user with this email is not found.')}
            return Response(message, status=status.HTTP_200_OK)
        else:
            user = qs.first()
            if not user.is_active:
                message = {'message': _('The user with this email has been deleted.')}
                return Response(message, status=status.HTTP_200_OK)

        message = {'message': _('The request for reset password has been send to your email.')}
        return Response(message, status=status.HTTP_200_OK)

class StudentListAPIView(ListAPIView):
    queryset = Student.objects.all()
    serializer_class = StudentSerializer

class UserListAPIView(ListAPIView):
    queryset = User.objects.filter(instructor__isnull=True).distinct()
    serializer_class = UserSerializer
