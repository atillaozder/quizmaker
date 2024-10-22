from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.shortcuts import get_object_or_404
from django.core.mail import send_mail
from utils.utils import unique_slug_generator
from account.models import Instructor
from quiz.models import Quiz, QuizParticipant
from course.models import Course

@receiver(pre_save, sender=Quiz)
def quiz_pre_save_receiver(sender, instance, *args, **kwargs):
	if not instance.slug:
		instance.slug = unique_slug_generator(instance)

	if instance.owner.is_instructor:
		instance.is_private = True

@receiver(post_save, sender=Quiz)
def quiz_post_save_receiver(sender, instance, created, *args, **kwargs):
	if created:
		qs_exist = Instructor.objects.filter(user=instance.owner).exists()
		if qs_exist:
			course = get_object_or_404(Course, id=instance.course.id)
			students = course.students.all()
			emails = []
			for student in students:
				# participant = QuizParticipant(quiz=instance, participant=student.user)
				# participant.save()
				emails.append(student.user.email)

			send_mail(
			    "A NEW QUIZ HAS BEEN CREATED",
			    "Hello from QuizMaker. You've been added to a quiz lately.",
			    'se301quizmaker@gmail.com',
			    emails,
			    fail_silently=False,
			)
		else:
			instance.course = None

	quizzes = Quiz.objects.filter(course=instance.course).filter(owner=instance.owner).all()
	quiz_count = quizzes.count()
	total_value = 0
	for quiz in quizzes:
	    total_value = total_value + quiz.percentage

	if total_value > 100 and instance.be_graded:
		instance.update_percentage(value=total_value)
