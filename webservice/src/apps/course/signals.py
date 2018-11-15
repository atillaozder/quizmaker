from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from utils.utils import unique_slug_generator
from course.models import Course

@receiver(pre_save, sender=Course)
def course_pre_save_receiver(sender, instance, *args, **kwargs):
	if not instance.slug:
		instance.slug = unique_slug_generator(instance)

@receiver(post_save, sender=Course)
def course_student_post_save_receiver(sender, instance, *args, **kwargs):
	for student in instance.students.all():
		profile = student.user.profile
		profile.courses.add(instance)
		profile.save()
