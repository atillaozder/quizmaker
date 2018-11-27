from rest_framework import serializers
from rest_framework.exceptions import ValidationError
from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _

from account.api.serializers import UserSerializer
from account.api.serializers import ParticipantSerializer
from question.api.serializers import QuestionSerializer
from quiz.models import Quiz, QuizParticipant
from question.models import ParticipantAnswer

User = get_user_model()

class QuizSerializer(serializers.ModelSerializer):
    owner_id = serializers.SerializerMethodField()
    owner_name = serializers.SerializerMethodField()
    course_name = serializers.SerializerMethodField()
    participants = ParticipantSerializer(many=True)
    questions = QuestionSerializer(many=True)

    class Meta:
        model = Quiz
        fields = (
            'id',
            'owner_id',
            'owner_name',
            'course_name',
            'name',
            'description',
            'start',
            'end',
            'be_graded',
            'percentage',
            'is_private',
            'participants',
            'questions',
        )

    def get_owner_id(self, instance):
        return instance.owner.id

    def get_owner_name(self, instance):
        return instance.owner.username

    def get_course_name(self, instance):
        if instance.course:
            return instance.course.name
        return None

class QuizCreateUpdateSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)

    class Meta:
        model = Quiz
        fields = (
            'id',
            'name',
            'description',
            'course',
            'participants',
            'questions',
            'start',
            'end',
            'be_graded',
            'percentage',
        )

class QuizAppendSerializer(serializers.ModelSerializer):

    class Meta:
        model = Quiz
        fields = (
            'id',
        )

class QuizParticipantAnswerSerializer(serializers.ModelSerializer):
    question = QuestionSerializer(many=False)

    class Meta:
        model = ParticipantAnswer
        fields = (
            'id',
            'question',
            'answer',
            'participant_id',
            'is_correct'
        )

class QuizParticipantSerializer(serializers.ModelSerializer):
    participant = UserSerializer(many=False)

    class Meta:
        model = QuizParticipant
        fields = '__all__'
