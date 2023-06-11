from django.urls import path
from . import views

urlpatterns = [
    path('user/', views.user, name='user'), 
    path('user/<id>', views.user, name='user'),
    path('user/<id>/festivals/', views.user_festivals, name="user_festivals"),
    path('user/<id>/festivals/<fest_id>', views.user_festivals, name="user_festivals"),

    path('festival/', views.festivals, name='festival'), 
    path('festival/<id>', views.festivals, name='festival'),

    path('festival/<id>/lineup/', views.festival_lineup, name='festival_lineup'),
    path('festival/<id>/lineup/<day>', views.festival_lineup, name='festival_lineup'),

    path('user/<id>/buddies/', views.user_buddy, name='user_buddies'),
    path('user/<id>/buddies/<buddy_id>', views.user_buddy, name='user_buddies'),

    path('qrcode/<id>', views.qrcodes, name='qrcode'),
]