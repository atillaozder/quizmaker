from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from question.models import Question, ParticipantAnswer
from quiz.models import Quiz, QuizParticipant

User = get_user_model()

class QuestionSerializer(serializers.ModelSerializer):
    quiz_id = serializers.IntegerField(write_only=True)

    class Meta:
        model = Question
        fields = (
            'id',
            'quiz_id',
            'question',
            'question_type',
            'answer',
        )

    def validate_quiz_id(self, id):
        qs_exists = Quiz.objects.filter(id=id).exists()
        if qs_exists:
            return id
        raise ValidationError(_('Quiz is not found.'))

    def create(self, validated_data):
        quiz_id = validated_data["quiz_id"]

        question = Question(
            question=validated_data['question'],
            question_type=validated_data['question_type'],
            answer=validated_data['answer']
        )

        question.save()
        quiz = Quiz.objects.filter(id=quiz_id).first()
        quiz.questions.add(question)
        quiz.save()

        return question

class ParticipantAnswerSerializer(serializers.ModelSerializer):

    class Meta:
        model = ParticipantAnswer
        fields = '__all__'

    def validate(self, data):
        participant = data['participant']
        quiz = data['quiz']
        question = data['question']
        if not Quiz.objects.filter(id=quiz.id).filter(questions__id=question.id).exists():
            raise ValidationError(_('This question does not belong to this quiz.'))

        qs_exists = QuizParticipant.objects.filter(quiz=quiz).filter(participant=participant).exists()
        if not qs_exists:
            raise ValidationError(_('You must first append to quiz to answer questions.'))
        return data

class ParticipantValidateSerializer(serializers.ModelSerializer):

    class Meta:
        model = ParticipantAnswer
        fields = ('is_correct',)
