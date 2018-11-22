from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from utils.utils import unique_slug_generator
from course.models import Course
from quiz.models import Quiz, QuizParticipant

@receiver(pre_save, sender=Course)
def course_pre_save_receiver(sender, instance, *args, **kwargs):
	if not instance.slug:
		instance.slug = unique_slug_generator(instance)

# @receiver(post_save, sender=Course)
# def course_student_post_save_receiver(sender, instance, created, *args, **kwargs):
# 	for student in instance.students.all():
# 		quizzes = Quiz.objects.filter(course=instance).all()
# 		for q in quizzes:
# 			 obj, created = QuizParticipant.objects.get_or_create(quiz=q, participant=student.user)
# 			 if created:
# 			     obj.save()
#
# 		profile = student.user.profile
# 		profile.courses.add(instance)
# 		profile.save()
