from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from django.shortcuts import get_object_or_404
from question.models import ParticipantAnswer

from quiz.models import QuizParticipant

@receiver(pre_save, sender=ParticipantAnswer)
def answer_pre_save_receiver(sender, instance, *args, **kwargs):
    if instance.question.question_type != "text":
        instance.is_validated = True
        if instance.answer.lower() == instance.question.answer.lower():
            instance.is_correct = True
            instance.point = instance.question.point
        else:
            instance.is_correct = False
            instance.point = 0

# @receiver(post_save, sender=ParticipantAnswer)
# def answer_post_save_receiver(sender, instance, created, *args, **kwargs):
    # all_answers = ParticipantAnswer.objects.filter(quiz=instance.quiz).filter(participant=instance.participant)
    # overall_grade = 0
    # for answer in all_answers:
    #     overall_grade = overall_grade + answer.point
    #
    # if overall_grade > 100:
    #     overall_grade = 100

    # p, created = QuizParticipant.objects.get_or_create(quiz_id=instance.quiz.id, participant_id=instance.participant.id)
    # p.grade = p.grade + instance.point
    # p.save()
