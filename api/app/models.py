from django.db import models

# Create your models here.
class User(models.Model):
    username = models.CharField(max_length=100)
    password = models.CharField(max_length=100)
    lat = models.FloatField(null=True)
    lon = models.FloatField(null=True)

class Festival(models.Model):
    name = models.CharField(max_length=100)
    location = models.CharField(max_length=100)
    lat = models.FloatField(null=True)
    lon = models.FloatField(null=True)
    date = models.DateField()

class UserFestival(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    festival = models.ForeignKey(Festival, on_delete=models.CASCADE)

class FestivalLineup(models.Model):
    festival = models.ForeignKey(Festival, on_delete=models.CASCADE)
    day = models.IntegerField()
    artist = models.CharField(max_length=100)
    start_time = models.TimeField()
    end_time = models.TimeField()
    stage = models.CharField(max_length=100)

class UserBuddy(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='user_buddy_set')
    buddy = models.ForeignKey(User, on_delete=models.CASCADE, related_name='buddy_user_set')