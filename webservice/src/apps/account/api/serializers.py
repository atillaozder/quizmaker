from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.contrib.auth.forms import PasswordResetForm
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from account.models import Student, Instructor

User = get_user_model()

class LoginSerializer(serializers.ModelSerializer):
    first_name  = serializers.CharField(read_only=True)
    last_name   = serializers.CharField(read_only=True)
    email       = serializers.EmailField(required=False, read_only=True, allow_blank=True)
    username    = serializers.CharField(required=False, allow_blank=True)
    password    = serializers.CharField(style={'input_type': 'password'}, write_only=True)
    user_type   = serializers.CharField(read_only=True)
    student_id  = serializers.CharField(required=False, read_only=True, allow_blank=True)
    is_approved = serializers.CharField(required=False, read_only=True, allow_blank=True)
    is_staff    = serializers.BooleanField(required=False, read_only=True)

    class Meta:
        model = User
        fields = (
            'id',
            'first_name',
            'last_name',
            'email',
            'username',
            'password',
            'user_type',
            'student_id',
            'is_staff',
            'is_approved',
        )

    def validate(self, data):
        usernameOrEmail = data.get('username', None)
        password = data['password']

        if not usernameOrEmail:
            raise ValidationError(_('The username or email can not be empty.'))

        queryset = User.objects.filter(username__iexact=usernameOrEmail)
        error_message = _('Please control the informations. Password is case sensitive.')

        if queryset.exists():
            user = queryset.first()
        else:
            qs = User.objects.filter(email__iexact=usernameOrEmail)
            if qs.exists():
                user = qs.first()
            else:
                raise ValidationError(error_message)

        if user:
            if not user.check_password(password):
                raise ValidationError(error_message)
            else:
                data['id'] = user.id
                data['email'] = user.email
                data['first_name'] = user.first_name
                data['last_name'] = user.last_name
                data['user_type'] = user.user_type
                data['is_staff'] = user.is_staff

                if user.is_student:
                    data['student_id'] = user.student.student_id
                elif user.is_instructor:
                    if not user.instructor.is_approved:
                        raise ValidationError(_('You should be approved by any admin before logging into system.'))
                    else:
                        data['is_approved'] = user.instructor.is_approved
        return data


class RegisterSerializer(serializers.ModelSerializer):
    id          = serializers.IntegerField(read_only=True)
    password    = serializers.CharField(min_length=8, style={'input_type': 'password'}, write_only=True)
    student_id  = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'first_name',
            'last_name',
            'email',
            'password',
            'user_type',
            'student_id'
        )

    def validate(self, data):
        user_type = data['user_type']
        if user_type == 'S':
            student_id = data.get('student_id', None)
            if not student_id:
                raise ValidationError(_('Student id cannot be empty.'))

            qs = Student.objects.filter(student_id__iexact=student_id)
            if qs.exists():
                raise ValidationError(_('This student id has already exists.'))

        return data

    def validate_username(self, username):
        qs = User.objects.filter(username__iexact=username)
        if qs.exists():
            raise ValidationError(_('This username has already exists.'))

        if len(username) < 1 or len(username) > 15:
            raise ValidationError(_('Username should be in range 1 and 15'))

        return username

    def validate_email(self, email):
        qs = User.objects.filter(email__iexact=email)
        if qs.exists():
            raise ValidationError(_('This email has already exists.'))
        return email

    def create(self, validated_data):
        user = User.objects.create_user(
            validated_data['username'],
            validated_data['email'],
            validated_data['password']
        )

        user.first_name = validated_data['first_name']
        user.last_name  = validated_data['last_name']
        user.user_type  = validated_data['user_type']
        user.save()

        if user.user_type == 'S':
            student_id = validated_data['student_id']
            student = Student(user=user, student_id=student_id)
            student.save()
        elif user.user_type == 'I':
            instructor = Instructor(user=user)
            instructor.save()

        return user

class UserSerializer(serializers.ModelSerializer):
    student_id = serializers.SerializerMethodField(read_only=True, allow_null=True)

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'first_name',
            'last_name',
            'student_id',
            'email',
            'is_active',
            'date_joined',
            'user_type',
            'gender',
        )

    def get_student_id(self, instance):
        if instance.is_student:
            return instance.student.student_id
        return None

class UserUpdateSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = (
            'first_name',
            'last_name',
            'email',
            'gender',
        )

    def update(self, instance, validated_data):
        instance.first_name = validated_data.get('first_name', instance.first_name)
        instance.last_name  = validated_data.get('last_name', instance.last_name)
        instance.email      = validated_data.get('email', instance.email)
        instance.gender     = validated_data.get('gender', instance.gender)
        instance.save()
        return instance

class ChangePasswordSerializer(serializers.ModelSerializer):
    old_password = serializers.CharField(style={'input_type': 'password'}, required=True)
    new_password = serializers.CharField(min_length=8, style={'input_type': 'password'}, required=True)
    confirm_password = serializers.CharField(style={'input_type': 'password'}, required=True)

    class Meta:
        model = User
        fields = (
            'old_password',
            'new_password',
            'confirm_password'
        )

class PasswordResetSerializer(serializers.ModelSerializer):
    email = serializers.EmailField()
    password_reset_form_class = PasswordResetForm
    subject_template_name = 'apps/account/registration/password_reset_subject.txt'

    class Meta:
        model = User
        fields = ('email',)

    def get_email_options(self):
        return {}

    def validate_email(self, value):
        self.reset_form = self.password_reset_form_class(data=self.initial_data)
        if not self.reset_form.is_valid():
            raise serializers.ValidationError(self.reset_form.errors)
        return value

    def save(self):
        from django.conf import settings
        request = self.context.get('request')
        opts = {
            'use_https': request.is_secure(),
            'from_email': getattr(settings, 'DEFAULT_FROM_EMAIL'),
            'request': request,
            'subject_template_name': self.subject_template_name,
            'domain_override': 'QuizMaker'
        }

        opts.update(self.get_email_options())
        self.reset_form.save(**opts)

class ParticipantSerializer(serializers.ModelSerializer):

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'email',
            'first_name',
            'last_name'
        )

class StudentSerializer(serializers.ModelSerializer):
    id = serializers.SerializerMethodField()
    username = serializers.SerializerMethodField()
    email = serializers.SerializerMethodField()
    first_name = serializers.SerializerMethodField()
    last_name = serializers.SerializerMethodField()

    class Meta:
        model = Student
        fields = ('id', 'username', 'email', 'first_name', 'last_name', 'student_id',)

    def get_id(self, instance):
        return instance.user.id

    def get_username(self, instance):
        return instance.user.username

    def get_email(self, instance):
        return instance.user.email

    def get_first_name(self, instance):
        return instance.user.first_name

    def get_last_name(self, instance):
        return instance.user.last_name
