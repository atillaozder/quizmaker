from django.urls import path, include

from .views import (
    QuizCreateAPIView,
    QuizListAPIView,
    QuizDeleteAPIView,
    QuizUpdateAPIView,
    QuizRetrieveAPIView,
    QuizOwnerListAPIView,
    QuizEndListAPIView,
    QuizWaitingListAPIView,
    QuizParticipantsListAPIView,
    QuizAppendView,
    QuizParticipantAnswerAPIView,
    QuizOwnerAnswerAPIView,
    QuizParticipantStatAPIView,
)

app_name = "api_quizzes"

urlpatterns = [
    path('', QuizListAPIView.as_view(), name='quizzes'),
    path('create', QuizCreateAPIView.as_view()),
    path('owner', QuizOwnerListAPIView.as_view()),
    path('answers', QuizOwnerAnswerAPIView.as_view()),
    path('participants', QuizParticipantsListAPIView.as_view()),
    path('participator/end', QuizEndListAPIView.as_view()),
    path('participator/waiting', QuizWaitingListAPIView.as_view()),
    path('participator/answers', QuizParticipantAnswerAPIView.as_view()),
    path('participator/stats', QuizParticipantStatAPIView.as_view()),
    path('<pk>', QuizRetrieveAPIView.as_view()),
    path('update/<pk>', QuizUpdateAPIView.as_view()),
    path('delete/<pk>', QuizDeleteAPIView.as_view()),
    path('append/<pk>', QuizAppendView.as_view()),
]
