from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.shortcuts import get_object_or_404
from question.models import ParticipantAnswer

from quiz.models import QuizParticipant

@receiver(pre_save, sender=ParticipantAnswer)
def answer_pre_save_receiver(sender, instance, *args, **kwargs):
    if instance.answer == instance.question.answer:
        instance.is_correct = True
        instance.point = instance.question.point
    else:
        instance.is_correct = False
        instance.point = 0

@receiver(post_save, sender=ParticipantAnswer)
def answer_post_save_receiver(sender, instance, created, *args, **kwargs):
    if instance.is_correct:
        correct_answers = ParticipantAnswer.objects.filter(quiz=instance.quiz).filter(participant=instance.participant).filter(is_correct=True)
        p, created = QuizParticipant.objects.get_or_create(quiz=instance.quiz, participant=instance.participant)
        overall_grade = 0
        for answer in correct_answers:
            overall_grade = overall_grade + answer.point

        if overall_grade > 100:
            overall_grade = 100

        p.grade = overall_grade
        p.save()
