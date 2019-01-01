from django.db import models
from django.utils.translation import gettext_lazy as _
from django.utils import timezone

from django.contrib.auth import get_user_model
User = get_user_model()

# Create your models here.
class Quiz(models.Model):
    owner           = models.ForeignKey(User,
                                        on_delete=models.SET_NULL,
                                        null=True,
                                        blank=True,
                                        related_name='owner')

    course          = models.ForeignKey('course.Course',
                                        on_delete=models.SET_NULL,
                                        null=True,
                                        blank=True)

    questions       = models.ManyToManyField('question.Question', blank=True)
    participants    = models.ManyToManyField('account.User',
                                             through='QuizParticipant',
                                             related_name='participants')
    start           = models.DateTimeField(_('Quiz Start'), default=timezone.now)
    end             = models.DateTimeField(_('Quiz End'), default=timezone.now)
    name            = models.CharField(_('Quiz Name'), max_length=50)
    description     = models.CharField(_('Quiz Description'), max_length=255, null=True, blank=True)
    slug            = models.SlugField(unique=True, blank=True, max_length=120)
    be_graded       = models.BooleanField(default=True)
    percentage      = models.DecimalField(_('Percentage'), default=0.0, max_digits=100, decimal_places=2)
    is_private      = models.BooleanField(_('Private Quiz'), default=False)
    is_deleted      = models.BooleanField(_('Quiz Deleted'), default=False)

    class Meta:
        verbose_name = _('Quiz')
        verbose_name_plural = _('Quizzes')

    def __str__(self):
        return self.name

    def update_percentage(self, value):
        new_value = value - self.percentage
        if value - self.percentage > 100:
            self.percentage = 0
        else:
            self.percentage = 100 - new_value

        self.save()

class QuizParticipant(models.Model):
    quiz        = models.ForeignKey(Quiz, on_delete=models.SET_NULL, null=True, blank=True)
    participant = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)

    grade       = models.DecimalField(_('Quiz Grade'),
                                      default=0.0,
                                      max_digits=100,
                                      decimal_places=2)

    completion  = models.DecimalField(_('Completion'),
                                      default=0.0,
                                      max_digits=100,
                                      decimal_places=2)

    finished_in = models.CharField(_('Completion Time'), max_length=50, blank=True)

    class Meta:
        verbose_name = _('Quiz Participant')
        verbose_name_plural = _('Quiz Participants')
        unique_together = ("quiz", "participant")

    def __str__(self):
        return self.quiz.owner.username
