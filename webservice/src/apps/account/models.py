from django.db import models
from django.contrib.auth.validators import UnicodeUsernameValidator
from django.urls import reverse
from django.utils.translation import gettext_lazy as _
from django.utils import timezone
from django.conf import settings
from django.contrib.auth.models import (
    AbstractBaseUser,
    BaseUserManager,
    PermissionsMixin
)


class UserQuerySet(models.query.QuerySet):
    def all(self):
        return self.filter(is_active=True)

class UserManager(BaseUserManager):
    def get_queryset(self):
        return UserQuerySet(self.model, using=self._db)

    def _create_user(self, username, email, password, **extra_fields):
        """
        Create and save a user with the given, email, and password.
        """
        if not username:
            raise ValueError('The username can not be empty')
        if not email:
            raise ValueError('The email can not be empty')
        email = self.normalize_email(email)
        user = self.model(
            username=username,
            email=email,
            **extra_fields
        )
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_user(self, username=None, email=None, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', False)
        extra_fields.setdefault('is_superuser', False)
        return self._create_user(username, email, password, **extra_fields)

    def create_superuser(self, username, email, password, **extra_fields):
	    extra_fields.setdefault('is_staff', True)
	    extra_fields.setdefault('is_superuser', True)

	    if extra_fields.get('is_staff') is not True:
	        raise ValueError('Superuser must have is_staff=True.')
	    if extra_fields.get('is_superuser') is not True:
	        raise ValueError('Superuser must have is_superuser=True.')

	    return self._create_user(username, email, password, **extra_fields)

# Create your models here.

class User(AbstractBaseUser, PermissionsMixin):
    username_validator = UnicodeUsernameValidator()

    FEMALE = _('female')
    MALE = _('male')

    GENDER_CHOICES = (
    	(FEMALE, _('Female')),
    	(MALE, _('Male')),
    )

    INSTRUCTOR = _('instructor')
    STUDENT = _('student')

    USERTYPE_CHOICES = (
        (INSTRUCTOR, _('Instructor')),
        (STUDENT, _('Student'))
    )

    username = models.CharField(_('Username'),
                                unique=True,
                                max_length=30,
                                validators=[username_validator],
                                error_messages={
                                    'unique': _("The username is already exist.")
                                })

    email = models.EmailField(_('E-Mail Address'), max_length=255, unique=True)
    first_name = models.CharField(_('First Name'), max_length=30, blank=True)
    last_name = models.CharField(_('Last Name'), max_length=150, blank=True)
    date_joined = models.DateTimeField(_('Date Joined'), default=timezone.now)

    is_active = models.BooleanField(_('Active Status'),
                                    default=True,
                                    help_text=_(
                                        'Designates whether this user account should be considered active.'
										' Set this flag to False instead of deleting accounts.'
                                        ))

    is_staff = models.BooleanField(_('Staff Status'),
                                   default=False,
                                   help_text=_(
                                       'Designates whether this user can access the admin site.'
                                       ))

    is_superuser = models.BooleanField(_('SuperUser Status'),
                                       default=False,
                                       help_text=_(
                                           'Designates that this user has all permissions'
											' without explicitly assigning them.'
                                            ))

    user_type = models.CharField(_('User Type'), max_length=50, choices=USERTYPE_CHOICES)
    gender = models.CharField(_('Gender'), max_length=10, choices=GENDER_CHOICES)

    EMAIL_FIELD 	 = 'email'
    USERNAME_FIELD 	 = 'username'
    REQUIRED_FIELDS  = ['email']

    objects = UserManager()

    class Meta:
        verbose_name = _('User')
        verbose_name_plural = _('Users')

    def __str__(self):
        return self.username

    def get_full_name(self):
        fullname = '{0} {1}'.format(self.first_name, self.last_name)
        if not fullname.strip():
        	fullname = self.username
        return fullname.strip()

    def get_short_name(self):
        first_name = self.first_name
        if not first_name:
        	first_name = self.username
        return first_name

class Instructor(models.Model):
    user = models.OneToOneField('User', on_delete=models.CASCADE, primary_key=True)

    def __str__(self):
        return self.user.username

class Student(models.Model):
    user = models.OneToOneField('User', on_delete=models.CASCADE, primary_key=True)
    student_id = models.CharField(_('Student ID'),
                                  unique=True,
                                  max_length=50,
                                  error_messages={
                                    'unique': _("The student id is already exist.")
                                  })

    def __str__(self):
        return self.user.username
