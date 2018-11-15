from django.db.models.signals import post_save
from django.dispatch import receiver
from account.models import User, Profile, Instructor

@receiver(post_save, sender=User)
def user_post_save_receiver(sender, instance, created, *args, **kwargs):
    if created:
        profile = Profile(user=instance)
        profile.save()
