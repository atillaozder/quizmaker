from django.contrib import admin
from question.models import Question

# Register your models here.
@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    list_display  = ('question_type', 'answer')
