from django.urls import path
from . import views

urlpatterns = [
    path('user/', views.user, name='user'), 
    path('user/<id>', views.user, name='user'), 
]
