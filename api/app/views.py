from django.views.decorators.csrf import csrf_exempt
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status

from django.forms.models import model_to_dict

from app.models import User

import json

@api_view(["GET", "POST", "PATCH", "DELETE"]) 
@csrf_exempt
def user(request, id=None):
    if request.method == "GET" or request.method == "PATCH" or request.method == "DELETE":
        if id is None:
            return Response({"message": "ID required"}, status=status.HTTP_400_BAD_REQUEST)
        
        if not id.isdigit():
            return Response({"message": "ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)
    
        try:
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        
        if request.method == "DELETE":
            user.delete()
            return Response({"message": "User deleted"}, status=status.HTTP_200_OK)
        
        elif request.method == "PATCH":
            data = json.loads(request.body)
            if "username" in data:
                user.username = data["username"]
            if "password" in data:
                user.password = data["password"]
            if "lat" in data:
                user.lat = data["lat"]
            if "lon" in data:
                user.lon = data["lon"]

            user.save()
            return Response(model_to_dict(user), status=status.HTTP_200_OK)
        
        else:
            return Response(model_to_dict(user), status=status.HTTP_200_OK)

    if request.method == "POST":
        data = json.loads(request.body)

        user = User.objects.create(username=data["username"], password=data["password"])
        user.save()

        return Response(model_to_dict(user), status=status.HTTP_201_CREATED)