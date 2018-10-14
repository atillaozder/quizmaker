from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from utils.utils import unique_slug_generator
from quiz.models import Quiz

@receiver(pre_save, sender=Quiz)
def quiz_pre_save_receiver(sender, instance, *args, **kwargs):
	if not instance.slug:
		instance.slug = unique_slug_generator(instance)

@receiver(post_save, sender=Quiz)
def quiz_post_save_receiver(sender, instance, *args, **kwargs):
	if instance.be_graded and instance.percentage == 0:
		instance.update_percentage()
