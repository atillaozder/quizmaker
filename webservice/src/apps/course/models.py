from django.db import models
from django.utils.translation import gettext_lazy as _

# Create your models here.
class Course(models.Model):
    owner       = models.ForeignKey('account.Instructor',
                                    on_delete=models.SET_NULL,
                                    null=True,
                                    blank=True,
                                    related_name='course')

    students    = models.ManyToManyField('account.Student', blank=True)
    name        = models.CharField(_('Course Name'), max_length=50)
    slug        = models.SlugField(unique=True, blank=True, max_length=120)
    timestamp   = models.DateTimeField(auto_now=True)
    updated     = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name = _('Course')
        verbose_name_plural = _('Courses')

    def __str__(self):
        return self.name
