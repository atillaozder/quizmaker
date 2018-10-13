from django.contrib import admin
from course.models import Course, CourseStudent

# Register your models here.
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    list_display = ('instructor', 'name')
    list_filter = ('instructor', 'name')

@admin.register(CourseStudent)
class CourseStudentAdmin(admin.ModelAdmin):
    list_display = ('course', 'student', 'grade')
    list_filter = ('grade',)
