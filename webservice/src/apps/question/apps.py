from django.apps import AppConfig


class QuestionConfig(AppConfig):
    name = 'question'

    def ready(self):
        import apps.question.signals
