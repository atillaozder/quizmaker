from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.shortcuts import get_object_or_404
from question.models import ParticipantAnswer

from quiz.models import QuizParticipant

@receiver(pre_save, sender=ParticipantAnswer)
def answer_pre_save_receiver(sender, instance, *args, **kwargs):
    if instance.answer == instance.question.answer:
        instance.is_correct = True
    else:
        instance.is_correct = False

@receiver(post_save, sender=ParticipantAnswer)
def answer_post_save_receiver(sender, instance, created, *args, **kwargs):
    if instance.is_correct:
        question_count = instance.quiz.questions.count()
        count_correct_answers = ParticipantAnswer.objects.filter(quiz=instance.quiz).filter(participant=instance.participant).filter(is_correct=True).count()
        p, created = QuizParticipant.objects.get_or_create(quiz=instance.quiz, participant=instance.participant)
        if count_correct_answers <= question_count:
            p.grade = (count_correct_answers / question_count) * 100
            p.save()
