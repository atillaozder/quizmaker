from django.contrib.auth import get_user_model
from django.utils.translation import gettext_lazy as _
from rest_framework import status
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
from question.api.serializers import (
    QuestionSerializer,
    ParticipantAnswerSerializer,
    ParticipantValidateSerializer
)

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
