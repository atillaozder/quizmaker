from django.contrib import admin
from question.models import Question, ParticipantAnswer

# Register your models here.
@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display  = ('question_type', 'answer')

@admin.register(ParticipantAnswer)
class QuestionAdmin(admin.ModelAdmin):
    list_display  = ('participant', 'question')
