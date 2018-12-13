from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from rest_framework import status
from rest_framework.response import Response
from django.core.mail import send_mail
from rest_framework.views import APIView
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    UpdateAPIView,
    GenericAPIView,
    DestroyAPIView,
    CreateAPIView,
)

from django.db import transaction
from account.api.permissions import IsAuthenticated
from question.api.serializers import (
    QuestionSerializer,
    ParticipantAnswerSerializer,
    ParticipantValidateSerializer
)
from quiz.models import QuizParticipant
from question.models import ParticipantAnswer, Question

class QuestionCreateAPIView(CreateAPIView):
    serializer_class = QuestionSerializer
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        if request.user.is_instructor:
            if not request.user.instructor.is_approved:
                return Response(
                    {'message': _('You should be approved by admin to create a question.')},
                    status=status.HTTP_400_BAD_REQUEST
                )
        # elif request.user.is_student:
        #     return Response(
        #         {'message': _('Students cannot create a question.')},
        #         status=status.HTTP_400_BAD_REQUEST
        #     )
        return super(QuestionCreateAPIView, self).create(request, *args, **kwargs)

class QuestionUpdateAPIView(UpdateAPIView):
    queryset = Question.objects.all()
    serializer_class = QuestionSerializer
    permission_classes = (IsAuthenticated,)

    def put(self, request, *args, **kwargs):
        return self.partial_update(request, *args, **kwargs)

class QuestionDeleteAPIView(DestroyAPIView):
    queryset = Question.objects.all()
    permission_classes = (IsAuthenticated,)

    def delete(self, request, *args, **kwargs):
        return super(QuestionDeleteAPIView, self).delete(request, *args, **kwargs)

class ParticipantAnswerCreateAPIView(CreateAPIView):
    serializer_class = ParticipantAnswerSerializer
    permission_classes = (IsAuthenticated,)

    def create(self, request, *args, **kwargs):
        if request.user.is_instructor:
            return Response(
                {'message': _('Instructors neither append a quiz nor answer a question.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return super(ParticipantAnswerCreateAPIView, self).create(request, *args, **kwargs)

class ParticipantValidateQuestionAPIView(UpdateAPIView):
    queryset = ParticipantAnswer.objects.all()
    permission_classes = (IsAuthenticated,)
    serializer_class = ParticipantValidateSerializer

    def put(self, request, *args, **kwargs):
        if not request.user.is_instructor:
            return Response(
                {'message': _('Only instructors can grade a quiz page.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return self.partial_update(request, *args, **kwargs)


class ParticipantAnswerQuestionsAPIView(APIView):

    def post(self, request, *args, **kwargs):
        if request.user.is_instructor:
            return Response(
                {'message': _('Instructors neither append a quiz nor answer a question.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        quiz_id = request.data.get("quiz_id")
        finished_in = request.data.get("finished_in")
        answers = request.data.get("answers")

        answers_arr = []

        for answer in answers:
            answers_arr.append(
                ParticipantAnswer(
                    participant_id=request.user.id,
                    quiz_id=quiz_id,
                    question_id=answer.get("question_id"),
                    answer=answer.get("answer")
                )
            )

        ParticipantAnswer.objects.bulk_create(answers_arr)
        obj, created = QuizParticipant.objects.get_or_create(
            participant_id=request.user.id,
            quiz_id=quiz_id,
        )
        obj.finished_in = finished_in
        obj.save()

        return Response()

class GradeParticipantPaperAPIView(APIView):

    def post(self, request, *args, **kwargs):
        if not request.user.is_instructor:
            return Response(
                [{
                    'message': "Only instructors can grade a quiz paper.",
                    'question_id': 0,
                    'question_point': 0,
                    'point': 0,
                }],
                status=status.HTTP_400_BAD_REQUEST
            )

        quiz_id = request.data.get("quiz_id")
        participant_id = request.data.get("participant_id")
        answers = request.data.get("answers")

        errors = []
        with transaction.atomic():
            for answer in answers:
                obj = None
                a_point = answer.get("point")
                qs = ParticipantAnswer.objects.filter(
                    participant_id=participant_id,
                    quiz_id=quiz_id,
                    question_id=answer.get("question_id"),
                )
                if qs.exists():
                    obj = qs.first()

                if obj:
                    if obj.question.point >= a_point:
                        obj.point = a_point
                        obj.save()
                        user = User.objects.filter(id=participant_id)
                        send_mail(
                		    "A QUIZ HAS BEEN GRADED",
                		    "Hello from QuizMaker. The quiz you have added was graded.",
                		    'se301quizmaker@gmail.com',
                		    [user.email],
                		    fail_silently=False,
                		)
                    else:
                        errors.append(
                            {
                                'message': "Question point is greater than given point.",
                                'question_id': obj.question.id,
                                'question_point': obj.question.point,
                                'point': a_point,
                            }
                        )
        if len(errors) == 0:
            return Response()
        return Response(errors, status=status.HTTP_400_BAD_REQUEST)
