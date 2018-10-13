from django.db import models
from django.utils.translation import gettext_lazy as _

# Create your models here.
class QuizParticipant(models.Model):
    quiz        = models.ForeignKey('Quiz', on_delete=models.CASCADE)
    participant = models.ForeignKey('account.User',
                                    on_delete=models.SET_NULL,
                                    null=True,
                                    blank=True)

    grade       = models.DecimalField(_('Quiz Grade'),
                                      default=0.0,
                                      max_digits=100,
                                      decimal_places=2)
    completion  = models.DecimalField(_('Completion'),
                                      default=0.0,
                                      max_digits=100,
                                      decimal_places=2)

    finished_in = models.DateTimeField()

    class Meta:
        verbose_name = _('Quiz Participant')
        verbose_name_plural = _('Quiz Participants')

    def __str__(self):
        return self.student.user.username

class Quiz(models.Model):
    owner           = models.ForeignKey('account.User',
                                        on_delete=models.CASCADE,
                                        related_name='owner')

    course          = models.OneToOneField('course.Course',
                                           on_delete=models.SET_NULL,
                                           null=True,
                                           blank=True)

    questions       = models.ManyToManyField('question.Question', blank=True)
    participants    = models.ManyToManyField('account.User',
                                             through='QuizParticipant',
                                             related_name='participants')
    start           = models.DateTimeField()
    end             = models.DateTimeField()
    name            = models.CharField(_('Quiz Name'), max_length=50)
    slug            = models.SlugField(unique=True, blank=True, max_length=120)
    percentage      = models.DecimalField(_('Percentage'), default=0.0, max_digits=100, decimal_places=2)

    class Meta:
        verbose_name = _('Quiz')
        verbose_name_plural = _('Quizzes')

    def __str__(self):
        return self.owner.username
