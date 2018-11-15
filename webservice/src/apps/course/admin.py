from django.contrib import admin
from course.models import Course

# Register your models here.
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('owner', 'name')
    list_filter = ('owner', 'name')
