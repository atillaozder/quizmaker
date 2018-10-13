from django.db import models
from django.utils.translation import gettext_lazy as _

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
    answer          = models.CharField(_('Answer'), max_length=255, blank=True)
