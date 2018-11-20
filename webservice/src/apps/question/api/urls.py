from django.urls import path, include

from .views import (
    QuestionCreateAPIView,
    ParticipantAnswerCreateAPIView,
    ParticipantValidateQuestionAPIView,
)

app_name = "api_question"

urlpatterns = [
    path('create', QuestionCreateAPIView.as_view()),
    path('answers/create', ParticipantAnswerCreateAPIView.as_view()),
    path('update/<pk>', ParticipantValidateQuestionAPIView.as_view()),
]
