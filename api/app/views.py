from django.views.decorators.csrf import csrf_exempt
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework import status

from django.forms.models import model_to_dict

from app.models import User, Festival, UserFestival, FestivalLineup, UserBuddy

import json

@api_view(["GET", "POST", "PATCH", "DELETE"]) 
@csrf_exempt
def user(request, id=None):
    if request.method == "GET" or request.method == "PATCH" or request.method == "DELETE":
        if id is None:
            return Response({"message": "ID required"}, status=status.HTTP_400_BAD_REQUEST)
    
        try:
            if id.isdigit():
                user = User.objects.get(id=id)
            else:
                user = User.objects.get(username=id)
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

@api_view(["GET", "POST", "PATCH", "DELETE"]) 
@csrf_exempt
def festivals(request, id=None):
    if request.method == "GET" or request.method == "PATCH" or request.method == "DELETE":
        if id is None:
            return Response({"message": "ID required"}, status=status.HTTP_400_BAD_REQUEST)
        
        if not id.isdigit():
            return Response({"message": "ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)
    
        try:
            festival = Festival.objects.get(id=id)
        except Festival.DoesNotExist:
            return Response({"message": "Festival not found"}, status=status.HTTP_404_NOT_FOUND)

        if request.method == "DELETE":
            festival.delete()
            return Response({"message": "Festival deleted"}, status=status.HTTP_200_OK)
        
        elif request.method == "PATCH":
            data = json.loads(request.body)
            if "name" in data:
                festival.name = data["name"]
            if "location" in data:
                festival.location = data["location"]
            if "lat" in data:
                festival.lat = data["lat"]
            if "lon" in data:
                festival.lon = data["lon"]
            if "date" in data:
                festival.date = data["date"]

            festival.save()
            return Response(model_to_dict(festival), status=status.HTTP_200_OK)
        
        else:
            return Response(model_to_dict(festival), status=status.HTTP_200_OK)

    if request.method == "POST":
        data = json.loads(request.body)

        festival = Festival.objects.create(name=data["name"], location=data["location"], lat=data["lat"], lon=data["lon"], date=data["date"])
        festival.save()

        return Response(model_to_dict(festival), status=status.HTTP_201_CREATED)

@api_view(["GET", "POST", "DELETE"]) 
@csrf_exempt
def user_festivals(request, id, fest_id=None):
    if request.method == "GET" or request.method == "DELETE": 
        if not id.isdigit():
            return Response({"message": "ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)
        
        if request.method == "GET":
            try:
                if fest_id is not None:
                    # verify if the festival is festival of the user
                    try:
                        UserFestival.objects.get(user=user, festival=fest_id)
                    except UserFestival.DoesNotExist:
                        return Response({"message": "User doesn't have this Festival"}, status=status.HTTP_404_NOT_FOUND)
                    
                    festivals = model_to_dict(Festival.objects.get(id=fest_id))
                else:
                    festivals = [model_to_dict(fest)["festival"] for fest in UserFestival.objects.filter(user=id)]

                return Response(festivals, status=status.HTTP_200_OK)
            except UserFestival.DoesNotExist:
                return Response([], status=status.HTTP_200_OK)
    
    if request.method == "POST":
        data = json.loads(request.body)


        try:
            festival = Festival.objects.get(id=data["festival"])
        except Festival.DoesNotExist:
            return Response({"message": "Festival not found"}, status=status.HTTP_404_NOT_FOUND)
        

        # verify if the festival doesn't already exist
        try:
            user_festival = UserFestival.objects.get(user=user, festival=festival)
            return Response({"message": "User already has this Festival"}, status=status.HTTP_400_BAD_REQUEST)
        except UserFestival.DoesNotExist:
            pass

        user_festival = UserFestival.objects.create(user=user, festival=festival)
        user_festival.save()

        return Response(model_to_dict(user_festival), status=status.HTTP_201_CREATED)

    if request.method == "DELETE":
        if fest_id is None:
            return Response({"message": "Festival ID required"}, status=status.HTTP_400_BAD_REQUEST)

        data = json.loads(request.body)

        try:
            # the first one
            user = User.objects.get(id=id)
        except User.DoesNotExist:
            return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        try:
            user_festival = UserFestival.objects.get(user=user, festival=fest_id)
        except UserFestival.DoesNotExist:
            return Response({"message": "User doesn't have this Festival"}, status=status.HTTP_404_NOT_FOUND)

        user_festival.delete()

        return Response({"message": "UserFestival deleted"}, status=status.HTTP_200_OK)
        

@api_view(["GET", "POST"]) 
@csrf_exempt
def festival_lineup(request, id, day=None):
    if request.method == "GET":
        if id is None:
            return Response({"message": "Festival ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        if day is not None:
            if not day.isdigit():
                return Response({"message": "ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)
            
            try:
                festival = Festival.objects.get(id=id)
            except Festival.DoesNotExist:
                return Response({"message": "Festival not found"}, status=status.HTTP_404_NOT_FOUND)
                
            if request.method == "GET":
                try:
                    lineup = [model_to_dict(artist) for artist in FestivalLineup.objects.filter(festival=id, day=day)]

                    return Response(lineup, status=status.HTTP_200_OK)
                except FestivalLineup.DoesNotExist:
                    return Response([], status=status.HTTP_200_OK)
        
        else:
            try:
                lineup = [model_to_dict(artist) for artist in FestivalLineup.objects.filter(festival=id)]

                return Response(lineup, status=status.HTTP_200_OK)
            except FestivalLineup.DoesNotExist:
                return Response([], status=status.HTTP_200_OK)

    if request.method == "POST":
        data = json.loads(request.body)

        try:
            festival = Festival.objects.get(id=data["festival"])
        except Festival.DoesNotExist:
            return Response({"message": "Festival not found"}, status=status.HTTP_404_NOT_FOUND)

        lineup = FestivalLineup.objects.create(festival=festival, artist=data["artist"], day=data["day"], start_time=data["start_time"], end_time=data["end_time"], stage=data["stage"])
        lineup.save()

        return Response(model_to_dict(lineup), status=status.HTTP_201_CREATED)
    
@api_view(["GET", "POST", "DELETE"]) 
@csrf_exempt
def user_buddy(request, id, buddy_id=None):
    if not id.isdigit():
        return Response({"message": "User ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)

    try:
        user = User.objects.get(id=id)
    except User.DoesNotExist:
        return Response({"message": "User not found"}, status=status.HTTP_404_NOT_FOUND)
    
    if request.method == "GET":
        if buddy_id is not None and not buddy_id.isdigit():
            return Response({"message": "Buddy ID must be a number"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            if buddy_id is not None:
                # verify if the buddy is buddy of the user
                try:
                    UserBuddy.objects.get(user=user, buddy=buddy_id)
                except UserBuddy.DoesNotExist:
                    return Response({"message": "User doesn't have this Buddy"}, status=status.HTTP_404_NOT_FOUND)

                buddies = model_to_dict(User.objects.get(id=buddy_id))
            else:
                if request.GET.get("content") == "username":
                    buddies = [model_to_dict(buddy.buddy)["username"] for buddy in UserBuddy.objects.filter(user=id)]
                else:
                    buddies = [model_to_dict(buddy)["buddy"] for buddy in UserBuddy.objects.filter(user=id)]

            return Response(buddies, status=status.HTTP_200_OK)
        except UserBuddy.DoesNotExist:
            return Response([], status=status.HTTP_200_OK)
    
    if request.method == "POST":
        data = json.loads(request.body)

        if int(id) == data["buddy"]:
            return Response({"message": "User cannot be his own Buddy"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            buddy = User.objects.get(id=data["buddy"])
        except User.DoesNotExist:
            return Response({"message": "Buddy not found"}, status=status.HTTP_404_NOT_FOUND)

        # verify if the buddy doesn't already exist
        try:
            UserBuddy.objects.get(user=user, buddy=data["buddy"])
            return Response({"message": "User already has this Buddy"}, status=status.HTTP_400_BAD_REQUEST)
        except UserBuddy.DoesNotExist:
            pass

        user_buddy = UserBuddy.objects.create(user=user, buddy=buddy)
        user_buddy.save()

        add_buddy_to_user = UserBuddy.objects.create(user=buddy, buddy=user)
        add_buddy_to_user.save()

        return Response({"message": "Added"}, status=status.HTTP_201_CREATED)

    if request.method == "DELETE":
        if buddy_id is None:
            return Response({"message": "Buddy ID required"}, status=status.HTTP_400_BAD_REQUEST)

        data = json.loads(request.body)

        try:
            user_buddy = UserBuddy.objects.get(user=user, buddy=buddy_id)
        except UserBuddy.DoesNotExist:
            return Response({"message": "User doesn't have this Buddy"}, status=status.HTTP_404_NOT_FOUND)

        user_buddy.delete()

        return Response({"message": "UserBuddy deleted"}, status=status.HTTP_200_OK)
        