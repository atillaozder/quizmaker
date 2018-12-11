from django.db import models
from django.utils.translation import gettext_lazy as _

from django.contrib.auth import get_user_model
User = get_user_model()

# Create your models here.
class Question(models.Model):

    TEXT = _('text')
    MULTICHOICE = _('multichoice')
    TRUEFALSE = _('truefalse')

    QUESTIONTYPE_CHOICES = (
        (TEXT, _('Text')),
        (MULTICHOICE, _('Multichoice')),
        (TRUEFALSE, _('True-False'))
    )

    question_type   = models.CharField(_('Question Type'),
                                       max_length=50,
                                       choices=QUESTIONTYPE_CHOICES,
                                       default=MULTICHOICE)

    answer          = models.TextField(_('Answer'), blank=True)
    question        = models.TextField(_('Question'), null=False, blank=False)
    point           = models.PositiveIntegerField(default=0)

    def __str__(self):
        return self.question

class ParticipantAnswer(models.Model):
    participant = models.ForeignKey(User,
                                    on_delete=models.SET_NULL,
                                    null=True,
                                    blank=True)

    quiz        = models.ForeignKey('quiz.Quiz', on_delete=models.CASCADE)
    question    = models.ForeignKey(Question, on_delete=models.CASCADE)
    is_correct  = models.BooleanField(_('Correct or not'), null=True, blank=True)
    point       = models.PositiveIntegerField(default=0)
    answer      = models.TextField(_('Participant Answer'),
                                   null=True,
                                   blank=True)

    class Meta:
        unique_together = ('quiz', 'question', 'participant')
