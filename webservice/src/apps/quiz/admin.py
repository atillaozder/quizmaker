from django.contrib import admin
from quiz.models import Quiz, QuizParticipant

# Register your models here.
@admin.register(Quiz)
class QuizAdmin(admin.ModelAdmin):
    list_display  = ('owner', 'course', 'start', 'end', 'percentage')

@admin.register(QuizParticipant)
class QuizParticipantAdmin(admin.ModelAdmin):
    list_display  = ('quiz', 'participant', 'grade', 'finished_in')
    list_filter = ('grade',)
