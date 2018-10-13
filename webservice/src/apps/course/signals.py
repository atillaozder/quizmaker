from django.db.models.signals import pre_save, post_save
from django.dispatch import receiver
from utils.utils import unique_slug_generator
from course.models import Course

@receiver(pre_save, sender=Course)
def product_pre_save_receiver(sender, instance, *args, **kwargs):
	if not instance.slug:
		instance.slug = unique_slug_generator(instance)
