from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from django.db.models import Count
from datetime import datetime
from rest_framework import status
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.generics import (
    RetrieveAPIView,
    ListAPIView,
    UpdateAPIView,
    GenericAPIView,
    DestroyAPIView,
    CreateAPIView,
)

from account.api.permissions import IsAuthenticated
from course.models import Course
from question.models import Question, ParticipantAnswer
from quiz.models import Quiz, QuizParticipant
from account.api.serializers import UserSerializer
from quiz.api.serializers import (
    QuizSerializer,
    QuizCreateUpdateSerializer,
    QuizAppendSerializer,
    QuizParticipantAnswerSerializer,
    QuizParticipantSerializer,
)

User = get_user_model()

class QuizEndListAPIView(ListAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

    def get_queryset(self):
        return Quiz.objects.filter(participants__id=self.request.user.id).filter(start__lte=datetime.now()).all()

class QuizWaitingListAPIView(ListAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

    def get_queryset(self):
        return Quiz.objects.filter(participants__id=self.request.user.id).filter(start__gt=datetime.now()).all()

class QuizOwnerListAPIView(ListAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

    def get_queryset(self):
        return Quiz.objects.filter(owner=self.request.user).all()

class QuizRetrieveAPIView(RetrieveAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

class QuizListAPIView(ListAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizSerializer

    def get_queryset(self):
        course_id = self.request.GET.get("course_id")
        if course_id:
            return Quiz.objects.filter(course_id=course_id).all()
        else:
            return Quiz.objects.annotate(num_questions=Count('questions')).filter(num_questions__gt=0).filter(is_private=False).filter(end__gt=datetime.now())

class QuizParticipantsListAPIView(ListAPIView):
    queryset = QuizParticipant.objects.none()
    serializer_class = QuizParticipantSerializer

    def get_queryset(self):
        quiz_id = self.request.GET.get("quiz_id")
        if quiz_id:
            qs = Quiz.objects.filter(id=quiz_id)
            if qs.exists():
                quiz = qs.first()
                return QuizParticipant.objects.filter(quiz=quiz).all()
        return super(QuizParticipantsListAPIView, self).get_queryset()

class QuizParticipantAnswerAPIView(APIView):

    def get(self, request, format='json', *args, **kwargs):
        quiz_id = request.GET.get("quiz_id")
        qs = Quiz.objects.all().filter(id=quiz_id)
        if qs.exists():
            end_qs = qs.filter(end__lte=datetime.now())
            if end_qs.exists():
                quiz = end_qs.first()
                is_participant = QuizParticipant.objects.filter(quiz=quiz).filter(participant=request.user)
                if is_participant:
                    data = []
                    for question in quiz.questions.all():
                        a_qs = ParticipantAnswer.objects.filter(question=question).filter(participant=request.user)
                        if a_qs.exists():
                            serializer = QuizParticipantAnswerSerializer(a_qs, many=True)
                            data.append(serializer.data)

                    if len(data) > 0:
                        return Response(data, status=status.HTTP_200_OK)
                    else:
                        return Response(
                            {'message': _('You should answer some questions before see the results.')},
                            status=status.HTTP_404_NOT_FOUND
                        )
                else:
                    return Response(
                        {'message': _('You are not in the list of participants.')},
                        status=status.HTTP_400_BAD_REQUEST
                    )
            else:
                return Response(
                    {'message': _('The quiz has not finished yet.')},
                    status=status.HTTP_400_BAD_REQUEST
                )
        else:
            return Response(
                {'message': _('Quiz is not found')},
                status=status.HTTP_404_NOT_FOUND
            )

class QuizParticipantStatAPIView(APIView):
    queryset = QuizParticipant.objects.all()
    serializer_class = QuizParticipantSerializer

    def get(self, request, format='json', *args, **kwargs):
        user_id = request.GET.get("user_id")
        quiz_id = request.GET.get("quiz_id")
        qs = QuizParticipant.objects.filter(quiz_id=quiz_id)
        if user_id:
            qs = qs.filter(participant_id=user_id)
        serializer = QuizParticipantSerializer(qs, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class QuizOwnerAnswerAPIView(APIView):

    def get(self, request, format='json', *args, **kwargs):
        quiz_id = request.GET.get("quiz_id")
        user_id = request.GET.get("user_id")

        qs = Quiz.objects.filter(id=quiz_id).filter(owner=request.user)
        if qs.exists():
            quiz = qs.first()
            data = []
            for question in quiz.questions.all():
                a_qs = ParticipantAnswer.objects.filter(question=question).filter(participant_id=user_id)
                if a_qs.exists():
                    serializer = QuizParticipantAnswerSerializer(a_qs, many=True)
                    data.append(serializer.data)

            if len(data) > 0:
                return Response(data, status=status.HTTP_200_OK)
            else:
                return Response(
                    {'message': _('Not found any answer for this quiz with this user.')},
                    status=status.HTTP_404_NOT_FOUND
                )
        return Response(
            {'message': _('Quiz is not found')},
            status=status.HTTP_404_NOT_FOUND
        )

class QuizAppendView(UpdateAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizAppendSerializer
    permission_classes = (IsAuthenticated,)

    def put(self, request, *args, **kwargs):
        object = self.get_object()
        if request.user.is_instructor:
            return Response(
                {'message': _('Instructors cannot participate in a quiz.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        if object.owner == request.user:
            return Response(
                {'message': _('You cannot participate in your own quiz.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        if object.is_private:
            return Response(
                {'message': _('You cannot participate in a private quiz.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        if object.end < datetime.now():
            return Response(
                {'message': _('Quiz has ended.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        if object.start > datetime.now():
            return Response(
                {'message': _('Quiz has not started yet.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return self.partial_update(request, *args, **kwargs)

    def perform_update(self, serializer):
        object = self.get_object()
        qp, created = QuizParticipant.objects.get_or_create(quiz=object, participant=self.request.user)
        serializer.save()

class QuizDeleteAPIView(DestroyAPIView):
    queryset = Quiz.objects.all()

    def delete(self, request, *args, **kwargs):
        qs = Quiz.objects.filter(pk=kwargs['pk'])
        if qs.filter(start__lte=datetime.now()).filter(end__gte=datetime.now()).exists():
            return Response(
                {'message': _('You cannot delete the selected quiz because it has already started. You have to wait until it ends.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return super(QuizDeleteAPIView, self).delete(request, *args, **kwargs)

class QuizUpdateAPIView(UpdateAPIView):
    queryset = Quiz.objects.all()
    serializer_class = QuizCreateUpdateSerializer

    def put(self, request, *args, **kwargs):
        qs = Quiz.objects.filter(pk=kwargs['pk'])
        if qs.filter(start__lte=datetime.now()).filter(end__gte=datetime.now()).exists():
            return Response(
                {'message': _('You cannot update the selected quiz because it has already started. You have to wait until it ends.')},
                status=status.HTTP_400_BAD_REQUEST
            )
        return self.partial_update(request, *args, **kwargs)


class QuizCreateAPIView(CreateAPIView):
    serializer_class = QuizCreateUpdateSerializer

    def create(self, request, *args, **kwargs):
        if request.user.user_type == 'I':
            if not request.user.instructor.is_approved:
                return Response(
                    {'message': _('You should be approved by admin to create a quiz.')},
                    status=status.HTTP_400_BAD_REQUEST
                )
            else:
                qs = Course.objects.filter(owner=request.user.instructor).all()
                if qs.exists():
                    return super(QuizCreateAPIView, self).create(request, *args, **kwargs)
                else:
                    return Response(
                        {'message': _('You should have at least one course to create a quiz.')},
                        status=status.HTTP_400_BAD_REQUEST
                    )
        # elif request.user.user_type == 'S':
        #     return Response(
        #         {'message': _('Students cannot create a quiz.')},
        #         status=status.HTTP_400_BAD_REQUEST
        #     )

        return super(QuizCreateAPIView, self).create(request, *args, **kwargs)

    def perform_create(self, serializer):
        serializer.save(owner=self.request.user)
